//
//  ContentView.swift
//  MacSamplerSandboxPath
//
//  Created by Josip Cavar on 06.10.2022..
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    let conductor = Conductor()
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

class Conductor {
    let engine = AVAudioEngine()
    let preset = Bundle.main.url(forResource: "Default Sine", withExtension: "aupreset")!
    let sample = Bundle.main.url(forResource: "click", withExtension: "wav")!
    let documents = try! FileManager.default.url(
        for: .documentDirectory,
        in: .allDomainsMask,
        appropriateFor: nil,
        create: true
    )
    lazy var exs: URL = {
        documents.appendingPathComponent("EXS Factory Samples/")
    }()
    lazy var audioExs: URL = {
        documents.appendingPathComponent("Audio/EXS Factory Samples/")
    }()

    init() {
        // Clean up previous state
        try? FileManager.default.removeItem(at: exs)
        try? FileManager.default.removeItem(at: audioExs)

        // Prepare directories
        try! FileManager.default.createDirectory(
            at: exs,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try! FileManager.default.createDirectory(
            at: audioExs,
            withIntermediateDirectories: true,
            attributes: nil
        )

        try! FileManager.default.copyItem(
            at: sample,
            to: exs.appendingPathComponent("click.wav") // This crashes with sample not found
            // to: audioExs.appendingPathComponent("click.wav") // This works
        )
        let sampler = AVAudioUnitSampler()

        try! sampler.loadPreset(at: preset)

        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        try! engine.start()
    }
}
