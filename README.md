# Weatherglass — iOS wrapper (Capacitor + Codemagic, no Mac needed)

The App Store binary for **Weatherglass**. Modeled on the `1history-ios` pipeline that already
builds green on this Apple Developer account, but much simpler: Weatherglass is **one
self-contained HTML file** (the whole climate atlas is baked inline) and **no in-app purchases**.
The base app is **English only**; every other language (Thai, Filipino …) is an **On-Demand
Resource** — a small JSON pack (`odr/lang/lang-<code>.json`, 12–75 KB) the App Store hosts and the
device downloads when the reader picks that language, sha-verified against `www/lang-manifest.json`
by the native `WeatherglassLang` plugin. The web build (`build/weatherglass.html`) keeps everything
inline; `tools/ship_ios.py` produces the lean build for the store.

## How content flows

```
corpus repo (C:\1Weather):
    tools/build_weatherglass.py  ->  build/weatherglass.html   (the shipped single-file app)
    tools/ship_ios.py            ->  LEAN rebuild (English inline) as www/index.html + PWA shell + icons,
                                     language packs -> odr/lang/, digests -> www/lang-manifest.json

this repo:
    git tag v1.0.0               ->  Codemagic builds the IPA, configures Info.plist,
                                     signs, and ships to TestFlight
```

The app boots offline and reaches out only for the live weather/warnings the reader taps for
(Constitution Art. I). Native concerns: **geolocation**, **orientation** (phones portrait, iPad
landscape), the **privacy manifest**, **Preferences** (durable homes/settings), and the **language
ODR plugin** (`native/WeatherglassLang.swift`, registered by `native/MyViewController.swift`,
wired by `scripts/add_odr.rb`).

## One-time setup (browser only)

1. **App Store Connect** — the app record with Bundle ID **`live.weatherglass.app`** already exists
   (created during listing setup). The Bundle ID must match `capacitor.config.json` and
   `codemagic.yaml` exactly, or signing fails.
2. **Codemagic** — add this repo as an app. Signing is **manual**, exactly as 1history-ios:
   the `Paisarn` ASC API key is App-Manager (can make profiles, not certificates), so automatic
   signing fails. Instead `codemagic.yaml` references two identities stored under Team settings →
   Code signing identities: the profile `weatherglass_appstore` (generated at developer.apple.com
   for `live.weatherglass.app`, then "Fetch profiles" into Codemagic) and the distribution
   certificate `kaleido-1` (shared with 1History). Both already exist.
3. **Icon** — `assets/icon.png` (1024×1024) and `assets/splash.png` (2732×2732) are already here,
   generated from `store/icon/icon.svg`. `capacitor-assets` rasterizes every size in CI.

## Every release

```bash
# in the corpus repo (C:\1Weather), after the guards are green:
python3 tools/build_weatherglass.py
python3 tools/ship_ios.py            # fills weatherglass-ios/www/

# in THIS repo:
git add -A && git commit -m "release vX.Y.Z (app sha …)"
git push
# then start the build on Codemagic: weatherglass-ios → "Start new build" → branch main
# (a re-pushed tag of the same name does NOT trigger; use the button). Before a NEW App Store
# version, bump MARKETING_VERSION in codemagic.yaml first — a released version's train CLOSES.
```

Codemagic builds ~4 min → the build lands in App Store Connect (build number = Codemagic's
`PROJECT_BUILD_NUMBER`), the internal TestFlight group *Friends* gets it automatically, and the
external group *Family* needs it added by hand (TestFlight → Family → Builds → +). Release notes /
"What to test" text lives in `RELEASE_NOTES.md`.

Guards to run in the corpus repo before shipping (from a local copy, not a network mount — the
jsdom ones crawl there): `node tools/check_boot_offline.js`, `node tools/check_live_contract.js`,
`python3 tools/check_provenance.py`.

## What the CI does

- **Guard step** — refuses to build if `www/index.html` is missing, the PWA manifest link wasn't
  injected (`ship_ios.py` does that), or the `ship-manifest.json` shas don't match (a half-uploaded
  set fails in seconds, not in review).
- **Info.plist** — export-compliance exempt (`ITSAppUsesNonExemptEncryption=false`, HTTPS only);
  the location usage string; **iPhone portrait-only / iPad landscape-only** orientation with
  `UIRequiresFullScreen=true`; `UIDeviceFamily=[1,2]`.
- **Privacy manifest** — `native/PrivacyInfo.xcprivacy` copied into the app target: no tracking,
  **no collected data**, UserDefaults declared CA92.1.
- **No camera, no mic, no background location, no IAP, no accounts.**

## App Review notes (paste into the review form — heads off the usual rejection)

> Weatherglass is not a website wrapper. It ships a complete offline climate atlas (thousands of
> stations with 1991–2020 normals, historic storm tracks, record extremes) fully usable with no
> network, plus native geolocation. Live weather and official warnings are additive and only
> fetched when the user asks. This satisfies the minimum-functionality guideline (4.2): substantial
> native, offline value independent of any web content.
>
> Location is requested only in-use, only on an explicit tap, to fetch weather/warnings for the
> user's point; never stored, never background. Free app — no ads, no subscriptions, no accounts.

## Deliberately NOT here

- **No On-Demand Resources** — the atlas is inline in the single HTML; nothing is staged or fetched
  on consent.
- **No StoreKit/IAP** — Weatherglass is free, no products on either store.
- **No analytics, no accounts, no server of ours.** The only network traffic the app makes is the
  user-initiated weather/warning request to the whitelisted, verified sources.
