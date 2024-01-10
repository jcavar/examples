//
//  ContentView.swift
//  InteropCompilerCrash
//
//  Created by Josip Cavar on 10.01.2024..
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}


func make() {
    makeRenderBlock(3)
}
