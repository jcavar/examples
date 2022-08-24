//
//  CrashWhenConnectingToRawAudioUnitTests.swift
//  CrashWhenConnectingToRawAudioUnitTests
//
//  Created by Josip Cavar on 22.08.2022..
//

import XCTest
import AVFAudio

// When instantiating audio unit using C API,
// the app crashes on and having multi splitter,
// the app crashes when connecting new node.
// Interestingly when using kAudioUnitSubType_MultiChannelMixer
// everything works correctly. It seems that multi channel mixer
// has the knowledge about internal splitter
class CrashWhenConnectingToRawAudioUnitTests: XCTestCase {
    let matrixMixer = instantiate(
        componentDescription:
            AudioComponentDescription(
                componentType: kAudioUnitType_Mixer,
                componentSubType: kAudioUnitSubType_MatrixMixer,
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0
            )
        )
    let sampler = AVAudioUnitSampler()
    let engine = AVAudioEngine()

    func testConnectToRawAudioUnit() throws {
        engine.attach(sampler)
        engine.attach(matrixMixer)

        engine.connect(
            sampler,
            to: [
                AVAudioConnectionPoint(node: matrixMixer, bus: 0),
                AVAudioConnectionPoint(node: engine.mainMixerNode, bus: 0)
            ],
            fromBus: 0,
            format: nil
        )
        engine.connect(matrixMixer, to: engine.mainMixerNode, format: nil)
        try! engine.start()

        let reverb = AVAudioUnitReverb()
        engine.attach(reverb)

        engine.connect(
            sampler,
            to: [
                AVAudioConnectionPoint(node: matrixMixer, bus: 0),
                AVAudioConnectionPoint(node: reverb, bus: 0),
                AVAudioConnectionPoint(node: engine.mainMixerNode, bus: 0)
            ],
            fromBus: 0,
            format: nil
        )
        engine.connect(reverb, to: engine.mainMixerNode, fromBus: 0, toBus: 2, format: nil)
    }
}

func instantiate(componentDescription: AudioComponentDescription) -> AVAudioUnit {
    let semaphore = DispatchSemaphore(value: 0)
    var result: AVAudioUnit!
    AVAudioUnit.instantiate(with: componentDescription) { avAudioUnit, _ in
        guard let au = avAudioUnit else { fatalError("Unable to instantiate AVAudioUnit") }
        result = au
        semaphore.signal()
    }
    _ = semaphore.wait(wallTimeout: .distantFuture)
    return result
}
