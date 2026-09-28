// MyViewController.swift — registers the in-app plugin (Capacitor does not auto-discover plugin
// classes compiled into the app target; 1History build 7 shipped one unregistered and it did
// nothing). codemagic.yaml points Main.storyboard at this class after `cap add ios`.

import UIKit
import Capacitor

class MyViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(WeatherglassLangPlugin())
    }
}
