//
//  AppDelegate.swift
//  AUSamplerPluginView
//
//  Created by Josip Cavar on 27.11.2024..
//

import Cocoa
import AVFAudio
import CoreAudioKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let audio = Audio()
    @IBOutlet var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction func showAUSampler(_ sender: Any) {
        Task {
            let viewController = await audio.viewController()
            let audioWindow = NSWindow(contentViewController: viewController)
            audioWindow.orderFront(nil)
        }
    }
}

private class Audio {
    private var cached: NSViewController?
    let engine = AVAudioEngine()
    let sampler = AVAudioUnitSampler()

    init() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        try! engine.start()
    }

    func viewController() async -> NSViewController {
        // This needs to be cached.
        // Otherwise, the second request returns nil
        if let cached { return cached }
        cached = await sampler.auAudioUnit.requestViewController()!
        return cached!
    }
}
