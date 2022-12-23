import XCTest
import AVFAudio

final class IncorrectConnectionFormatTests: XCTestCase {
    let engine = AVAudioEngine()
    let mixer = AVAudioMixerNode()
    let player = AVAudioPlayerNode()
    var connectionFormat: AVAudioFormat!

    override func setUpWithError() throws {
        try super.setUpWithError()
        engine.attach(player)
        engine.attach(mixer)
        let format = engine.outputNode.outputFormat(forBus: 0)
        var settings = format.settings
        settings[AVSampleRateKey] = 48000
        connectionFormat = AVAudioFormat(settings: settings)

        engine.connect(mixer, to: engine.outputNode, format: connectionFormat)
        try! engine.start()
        engine.pause()
    }

    // This works ok. Our specified connection format was applied
    func testConnect() {
        engine.connect(player, to: mixer, format: connectionFormat)

        let format = player.auAudioUnit.outputBusses[0].format
        XCTAssertEqual(format.sampleRate, 48000)
    }

    // This doesn't work. It uses default sample rate
    func testOneConnectionPoint() {
        engine.connect(
            player,
            to: [AVAudioConnectionPoint(node: mixer, bus: 0)],
            fromBus: 0,
            format: connectionFormat
        )

        let format = player.auAudioUnit.outputBusses[0].format
        XCTAssertEqual(format.sampleRate, 48000)
    }

    // Interestingly, this does work. Specified format is applied
    func testTwoConnectionPoint() {
        engine.connect(
            player,
            to: [
                AVAudioConnectionPoint(node: mixer, bus: 0),
                AVAudioConnectionPoint(node: mixer, bus: 1),
            ],
            fromBus: 0,
            format: connectionFormat
        )

        let format1 = mixer.auAudioUnit.inputBusses[0].format
        let format2 = mixer.auAudioUnit.inputBusses[1].format
        XCTAssertEqual(format1.sampleRate, 48000)
        XCTAssertEqual(format2.sampleRate, 48000)
    }
}
