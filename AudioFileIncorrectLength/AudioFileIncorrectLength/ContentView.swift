//
//  ContentView.swift
//  AudioFileIncorrectLength
//
//  Created by Josip Cavar on 03.07.2023..
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    let url = Bundle.main.url(forResource: "test", withExtension: "wav")!

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            read()
        }
    }

    func read() {
        let readFile = try! AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(
            pcmFormat: .init(
                standardFormatWithSampleRate: 44100,
                channels: 1
            )!,
            frameCapacity: AVAudioFrameCount(readFile.length)
        )!
        try! readFile.read(into: buffer)
        print("Buffer length: \(buffer.frameLength)")
        print("Expected buffer length: \(readFile.length)")
    }
}
