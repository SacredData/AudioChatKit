//
//  ChatKitDemoApp.swift
//  ChatKitDemo
//
//  Created by Andrew Grathwohl on 8/29/23.
//

import AudioKit
import AVFoundation
import ChatKit2
import SwiftUI

@main
struct ChatKitDemoApp: App {
  @State var configurator: AudioConfigHelper = .init()
  @State var isPlaying: Bool = false
  @State var conductor: AudioConductor = .shared
  var preferredLocalization: String = ""
  var downloadMan: MessageDownloader = .shared
  
    init() {
        conductor.start()
        Log(preferredLocalization)
        Log(conductor)
        Log(conductor.engine)
        Log(conductor.playerMan.player)
        //Log(conductor.recordMan)
        doTheDl()
    }
    
    func doTheDl() {
        Task {
            try! await downloadMan.download(url: URL(string:"https://s3.amazonaws.com/sonicmultiplicities.audio/feed/SMOLD_017.mp3")!)
        }
        let file = try! AVAudioFile(forReading: downloadMan.downloadDir.appendingPathComponent("test.mp3"))
        let msg = Message(audioFile: file, author: nil)
        Log("made msg from local file")
        Log(msg)
        try! conductor.playerMan.newLocalMessage(msg: msg)
    }
  
    var body: some Scene {
        WindowGroup {
          ContentView(audioConfigHelper: self.$configurator,
                      audioConductor: self.$conductor,
                      isPlaying: self.$isPlaying)
        }
    }
}
