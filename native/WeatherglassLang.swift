// WeatherglassLang.swift — language packs as On-Demand Resources (modelled on 1History's loadLang).
//
// THE CONTRACT (fixed by the app, build/weatherglass.html loadLangPack()):
//   window.Capacitor.Plugins.WeatherglassLang.loadLang({code}) -> Promise<{json: string}>
// The base app ships ENGLISH ONLY. Each other language is its own On-Demand Resource, tagged
// `lang-<code>` (odr/lang/lang-<code>.json, wired by scripts/add_odr.rb): the App Store hosts it and
// the device downloads it (~30–80 KB) only when the reader picks that language. Its sha256 rides
// inside the signed app in www/lang-manifest.json and is verified before the JSON is trusted — a
// pack that does not match is refused, not "handled".
//
// A FAILED request is discarded (begin runs once per NSBundleResourceRequest instance); a successful
// one is kept resident so a re-pick is instant and the OS keeps the pack on the device.
//
// Registration: Capacitor does NOT auto-discover plugin classes compiled into the app target —
// MyViewController.capacitorDidLoad registers this instance, and codemagic.yaml points the
// storyboard at MyViewController. (1History build 7 shipped without that and the plugin was dead.)

import Foundation
import Capacitor
import CryptoKit

@objc(WeatherglassLangPlugin)
public class WeatherglassLangPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "WeatherglassLangPlugin"
    public let jsName = "WeatherglassLang"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "loadLang", returnType: CAPPluginReturnPromise),
    ]

    private static var langRequests: [String: NSBundleResourceRequest] = [:]
    private static var langInFlight: Set<String> = []

    private func langSha(_ code: String) -> String? {
        guard let url = Bundle.main.url(forResource: "lang-manifest", withExtension: "json", subdirectory: "public")
                ?? Bundle.main.url(forResource: "lang-manifest", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let langs = obj["langs"] as? [String: Any],
              let meta = langs[code] as? [String: Any],
              let sha = meta["sha256"] as? String else { return nil }
        return sha
    }

    private func deliver(_ call: CAPPluginCall, _ code: String) {
        guard let url = Bundle.main.url(forResource: "lang-\(code)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            call.reject("language resource not found after download"); return
        }
        // No manifest digest = no trust. The manifest is part of the signed app; a pack it does not
        // name is not ours to load.
        guard let want = langSha(code) else { call.reject("no digest for \(code) in lang-manifest.json"); return }
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        guard digest == want.lowercased() else { call.reject("language refused: sha256 mismatch for \(code)"); return }
        guard let json = String(data: data, encoding: .utf8) else { call.reject("language is not UTF-8"); return }
        call.resolve(["json": json])
    }

    @objc func loadLang(_ call: CAPPluginCall) {
        guard let code = call.getString("code"), !code.isEmpty,
              code.range(of: "^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,4})?$", options: .regularExpression) != nil else {
            call.reject("loadLang needs a language code"); return
        }
        if WeatherglassLangPlugin.langRequests[code] != nil {          // resident from a previous success
            DispatchQueue.main.async { self.deliver(call, code) }
            return
        }
        if WeatherglassLangPlugin.langInFlight.contains(code) {
            call.reject("a download is already in progress for \(code)"); return
        }
        WeatherglassLangPlugin.langInFlight.insert(code)
        let req = NSBundleResourceRequest(tags: ["lang-\(code)"])
        req.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent
        req.conditionallyBeginAccessingResources { available in
            if available {
                WeatherglassLangPlugin.langRequests[code] = req
                DispatchQueue.main.async {
                    WeatherglassLangPlugin.langInFlight.remove(code)
                    self.deliver(call, code)
                }
                return
            }
            req.beginAccessingResources { error in
                DispatchQueue.main.async {
                    WeatherglassLangPlugin.langInFlight.remove(code)
                    if let error = error {
                        call.reject("language download failed: \(error.localizedDescription)")
                    } else {
                        WeatherglassLangPlugin.langRequests[code] = req
                        self.deliver(call, code)
                    }
                }
            }
        }
    }
}
