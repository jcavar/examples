//
//  SamplerCleanupBugTests.swift
//  SamplerCleanupBugTests
//
//  Created by Josip Cavar on 20.08.2022..
//

import XCTest
import AVFAudio

// You can put a symbolic breakpoint on `SamplerBase::Cleanup`
// This will be called when sampler is cleaned up
class SamplerCleanupBugTests: XCTestCase {
    let file = Bundle(for: SamplerCleanupBugTests.self).url(forResource: "sample", withExtension: "m4a")!

    var engine: AVAudioEngine!
    var sampler: AVAudioUnitSampler!

    override func setUp() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        try! sampler.loadAudioFiles(at: [file])
        engine.attach(sampler)
    }

    // Naive approach cleans up the sampler
    func testSamplerNotCleanedUpWhenConnectingEffect() {
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        try! engine.start()
        let reverb = AVAudioUnitReverb()
        engine.attach(reverb)
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
        engine.connect(sampler, to: reverb, format: nil)

        assertNotCleanedUp()
    }

    // Only having a splitter still doesn't save the sampler
    func testSamplerNotCleanedUpWhenReconnectingSplitter() {
        let reverb = AVAudioUnitReverb()
        engine.attach(reverb)
        // This creates internal multi splitter
        engine.connect(
            sampler,
            to: [
                AVAudioConnectionPoint(node: reverb, bus: 0),
                AVAudioConnectionPoint(node: engine.mainMixerNode, bus: 0),
            ],
            fromBus: 0,
            format: nil
        )
        try! engine.start()
        let reverb2 = AVAudioUnitReverb()
        engine.attach(reverb2)
        engine.connect(reverb2, to: engine.mainMixerNode, format: nil)
        engine.connect(sampler, to: reverb2, format: nil)

        assertNotCleanedUp()
    }


    // Only this approach works. It seems that splitter is somehow able to save
    // the sampler from cleanup, but very specific steps have to be followed
    func testSamplerNotCleanedUpWhenReconnectingSplitterPoints() {
        let reverb = AVAudioUnitReverb()
        engine.attach(reverb)
        // This creates internal multi splitter
        engine.connect(
            sampler,
            to: [
                AVAudioConnectionPoint(node: reverb, bus: 0),
                AVAudioConnectionPoint(node: engine.mainMixerNode, bus: 0),
            ],
            fromBus: 0,
            format: nil
        )
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
        try! engine.start()
        let reverb2 = AVAudioUnitReverb()
        engine.attach(reverb2)

        // This has to be done this way. If we only connect to reverb2 and mainMixerNode, it will cleanup the sampler
        engine.connect(
            sampler,
            to: [
                AVAudioConnectionPoint(node: reverb, bus: 0),
                AVAudioConnectionPoint(node: engine.mainMixerNode, bus: 0),
                AVAudioConnectionPoint(node: reverb2, bus: 0),
            ],
            fromBus: 0,
            format: nil
        )

        engine.connect(reverb2, to: engine.mainMixerNode, format: nil)

        assertNotCleanedUp()

        // We now can detach the effect that we don't need and chain is in a good state
        engine.disconnectNodeOutput(reverb2)
        engine.detach(reverb2)
        print(engine)

        assertNotCleanedUp()
    }

    func assertNotCleanedUp() {
        // If sampler is cleaned up, the default Sine wave preset is loaded and we lose
        // all the cached samples
        let files = sampler.auAudioUnit.fullState?["file-references"] as? NSDictionary
        XCTAssertEqual(files?.count, 1)}
}
