import XCTest
import AVFAudio

final class AddToEmptyMixerBugTests: XCTestCase {
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let sampler = AVAudioUnitSampler()
    let mixer = AVAudioMixerNode()
    let subMixer = AVAudioMixerNode()

    override func setUpWithError() throws {
        try super.setUpWithError()
        engine.attach(player)
        engine.attach(sampler)
        engine.attach(mixer)
        engine.attach(subMixer)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)

        try engine.start()
    }

    func testAddingToMixerWorks() throws {
        engine.connect(player, to: mixer, format: nil)
        player.play()
    }

    // This fails with:
    // player started when in a disconnected state (com.apple.coreaudio.avfaudio)
    // Printing engine's underlying graph also shows that graph is not wired correctly
    func testAddingToSubmixerWorks() throws {
        engine.connect(subMixer, to: mixer, format: nil)
        engine.connect(player, to: subMixer, format: nil)
        player.play()
    }
}
