//
//  ContentView.swift
//  AudioPlayerSampleTimeOutOfSync
//
//  Created by Josip Cavar on 22.09.2022..
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    let conductor = Conductor()
    var body: some View {
        Button("Toggle") {
            conductor.toggle()
        }
    }
}

// Steps to reproduce two file players out of sync after stop.
// One player is panned to left and another to right for easier audition.
// Players play in perfect sync first time. But after stopping them, they go out of sync
class Conductor {
    let file = try! AVAudioFile(forReading: Bundle.main.url(forResource: "click", withExtension: "wav")!)
    let engine = AVAudioEngine()
    var player1 = AVAudioPlayerNode()
    let player2 = AVAudioPlayerNode()

    init() {
        engine.attach(player1)
        engine.attach(player2)
        engine.connect(player1, to: engine.mainMixerNode, format: nil)
        engine.connect(player2, to: engine.mainMixerNode, format: nil)
        player1.pan = -1
        player2.pan = 1
        try! engine.start()
        schedule()
    }

    func toggle() {
        if player1.isPlaying {
            player1.stop()
            player2.stop()
            schedule()
            engine.pause()
        } else {
            try! engine.start()
            let time = player1.lastRenderTime!.sampleTime
            let t = AVAudioTime(sampleTime: time, atRate: 44100)
            player1.play(at: t)
            player2.play(at: t)
        }
    }

    func schedule() {
        for i in 0...1000  {
            let time = AVAudioTime(
                sampleTime: Int64(i) * file.length,
                atRate: 44100
            )
            // These two should be equivalent, using nil for time will schedule buffers one after the other
            player1.scheduleFile(file, at: nil)
            player2.scheduleFile(file, at: time)

            // If we use nil for the second player, they stay in sync even after stopping the player
            // player2.scheduleFile(file, at: nil)
        }
    }
}
