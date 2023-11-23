//
//  ContentView.swift
//  AudioEngineAsan
//
//  Created by Josip Cavar on 26.10.2023..
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            let engine = AVAudioEngine()
            _ = engine.mainMixerNode
            let node = engine.outputNode
            print(node)
        }
    }
}

#Preview {
    ContentView()
}
