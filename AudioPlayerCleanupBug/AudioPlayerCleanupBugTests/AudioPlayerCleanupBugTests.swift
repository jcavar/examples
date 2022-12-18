import XCTest
import AVFAudio

class AudioPlayerCleanupBugTests: XCTestCase {
    let file = Bundle(for: AudioPlayerCleanupBugTests.self).url(forResource: "sample", withExtension: "m4a")!

    var engine: AVAudioEngine!
    var player: AVAudioPlayerNode!

    override func setUp() {
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        engine.attach(player)
        player.scheduleFile(try! AVAudioFile(forReading: file), at: nil)
    }

    func testPlayerNotStoppedWhenConnectingEffect() {
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        try! engine.start()
        player.play()
        XCTAssertTrue(player.isPlaying)

        let reverb = AVAudioUnitReverb()
        engine.attach(reverb)
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
        // It is still working here
        XCTAssertTrue(player.isPlaying)

        // This stops the player
        engine.connect(player, to: reverb, format: nil)
        XCTAssertTrue(player.isPlaying)
    }
}
