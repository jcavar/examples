//
//  ContentView.swift
//  SwiftUIListLeak
//
//  Created by Josip Cavar on 02.03.2023..
//

import SwiftUI

class Item: Identifiable {
    let id: String

    init(id: String) {
        self.id = id
    }

    deinit {
        print("deinit")
    }
}

struct ContentView: View {
    @State private var data = [
        Item(id: "1"),
        Item(id: "2"),
        Item(id: "3")
    ]

    var body: some View {
        List {
            ForEach(data) { Text($0.id) }
                .onDelete { indexes in
                    data.remove(at: indexes.first!)
                }
        }
    }
}
