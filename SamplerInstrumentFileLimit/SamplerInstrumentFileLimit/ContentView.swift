import SwiftUI
import Combine
import Foundation
import CoreMIDI
import AVFAudio

struct ContentView: View {

    var body: some View {
        ProgressView()
            .task {
                configureLimit()
                var files = [AVAudioFile]()
                let original = Bundle.main.url(forResource: "sample-sound", withExtension: "caf")!

//                Crashes start to happen when number of loaded samples is higher than 256
                for sample in createSampleDuplicates(of: original, count: 257) {
                    let audioFile = try! AVAudioFile(forReading: sample)
//                    crashes only if files are retained in memory
                    files.append(audioFile)
                    let buffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!, frameCapacity: 230168)!
                    try! audioFile.read(into: buffer)
                }

                print("DONE")
            }
    }
}

func createSampleDuplicates(of original: URL, count: Int) -> [URL] {
    var urls = [URL]()
    for i in 0..<count {
        let copy = URL.documentsDirectory
            .appending(path: "sample-sound-\(i)")
            .appendingPathExtension("caf")

        try? FileManager.default.removeItem(at: copy)
        try! FileManager.default.copyItem(at: original, to: copy)

        urls.append(copy)
    }

    return urls
}

func configureLimit() {
    var limit: rlimit = rlimit()
    getrlimit(RLIMIT_NOFILE, &limit)
    // change this value to suit your needs
    limit.rlim_cur = 16384
    setrlimit(RLIMIT_NOFILE, &limit)
    getrlimit(RLIMIT_NOFILE, &limit)
}
