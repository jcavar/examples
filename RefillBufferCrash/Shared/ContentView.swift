import SwiftUI
import Combine
import Foundation
import CoreMIDI
import AVFAudio

struct ContentView: View {
    @State var conductor = Conductor()

    var body: some View {
        VStack {
            Button("Play Note") {
                (1...1000).forEach { _ in
                    let element: UInt8 = (0...127).randomElement()!
                    conductor.noteOn(note: element)
                    conductor.noteOff(note: element)
                }
            }
        }
    }
}


class Conductor {
    let engine = AVAudioEngine()
    let sampler = AVAudioUnitSampler()

    init() {
        let preset = Bundle.main.url(
            forResource: "EXS Factory Samples/Test Instrument",
            withExtension: "aupreset"
        )!
        engine.attach(sampler)
        engine.connect(sampler, to: engine.outputNode, format: nil)

        try! sampler.loadPreset(at: preset)
        try! engine.start()

        sampler.sendController(64, withValue: 127, onChannel: 0)
    }

    func noteOn(note: UInt8) {
        sampler.startNote(note, withVelocity: 127, onChannel: 0)
    }

    func noteOff(note: UInt8) {
        sampler.stopNote(note, onChannel: 0)
    }
}
