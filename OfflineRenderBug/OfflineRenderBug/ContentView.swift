//
//  ContentView.swift
//  OfflineRenderBug
//
//  Created by Josip Cavar on 10.10.2023..
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    let engine = AVAudioEngine()
    
    var body: some View {
        Text("Hello, world!")
        .onAppear {
            let node = AVAudioPlayerNode()
            let file = try! AVAudioFile(
                forReading: Bundle.main.url(
                    forResource: "noise",
                    withExtension: "m4a"
                )!
            )
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: nil)
            try! engine.enableManualRenderingMode(
                .offline,
                format: file.processingFormat,
                maximumFrameCount: 4096
            )
            try! engine.start()
            node.scheduleFile(file, at: nil)
            let buffer = AVAudioPCMBuffer(
                pcmFormat: engine.manualRenderingFormat,
                frameCapacity: engine.manualRenderingMaximumFrameCount
            )!
            node.play()
            while true {
                let status = engine.render(to: buffer, fullLength: file.length)
                guard status != .error else {
                    return
                }
                var average: Float = 0.0
                for i in 0...buffer.frameLength {
                    average += abs(buffer.floatChannelData![0][Int(i)])
                }
                print(average / Float(buffer.frameLength))
            }
        }
    }
}

// https://developer.apple.com/forums/thread/111249
private extension AVAudioEngine {
    func render(
        to buffer: AVAudioPCMBuffer,
        fullLength: AVAudioFramePosition
    ) -> AVAudioEngineManualRenderingStatus {
        if manualRenderingSampleTime < fullLength {
            let frameCount = fullLength - manualRenderingSampleTime
            let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
            return (try? renderOffline(framesToRender, to: buffer)) ?? .error
        } else {
            return .error
        }
    }
}
