//
//  IncorrectAVAudioNodeLatencyApp.swift
//  IncorrectAVAudioNodeLatency
//
//  Created by Josip Cavar on 16.01.2025..
//

import SwiftUI
import AVFAudio

@main
struct IncorrectAVAudioNodeLatencyApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Test")
                .onAppear {
                    setup()
                }
        }
    }
}

func setup() {
    let engine = AVAudioEngine()
    let stretch = AVAudioUnitTimePitch()
    let sampler = AVAudioUnitSampler()
    engine.attach(sampler)
    engine.attach(stretch)
    engine.connect(sampler, to: stretch, format: nil)
    engine.connect(stretch, to: engine.mainMixerNode, format: nil)
    try! engine.start()

    stretch.rate = 4

    print("Latency using AVAudioNode: \(stretch.latency)")
    print("Latency using AUAudioUnit: \(stretch.auAudioUnit.latency)")
}
