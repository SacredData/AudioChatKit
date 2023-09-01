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
  @State var msg: Message

    init() {
        //msg = doTheDl()
        let file = try! AVAudioFile(forReading: downloadMan.downloadDir.appendingPathComponent("test.mp3"))
        let mePeer = Peer(id: "afakeid", name: "Andrew Grathwohl", teams: nil, locale: Locale(identifier: "en-US"), phoneNumber: "2125555555", emailAddress: "andrew@storyboard.fm", me: true)
        msg = Message(audioFile: file,
                          author: mePeer,
                          date: "2023-09-01T15:57:54+0000",
                          feedId: "idofafeed",
                          teamName: "Name of a Team")
        Log("made msg from local file")
        conductor.start()
        Log(preferredLocalization)
        Log(conductor)
        Log(conductor.engine)
        Log(conductor.playerMan.player)
        //Log(conductor.recordMan)
    }
    
    func doTheDl() -> Message {
        Task {
            try! await downloadMan.download(url: URL(string:"https://s3.amazonaws.com/sonicmultiplicities.audio/feed/SMOLD_017.mp3")!)
        }
        let file = try! AVAudioFile(forReading: downloadMan.downloadDir.appendingPathComponent("test.mp3"))
        let mePeer = Peer(id: "afakeid", name: "Andrew Grathwohl", teams: nil, locale: Locale(identifier: "en-US"), phoneNumber: "2125555555", emailAddress: "andrew@storyboard.fm", me: true)
        let msg = Message(audioFile: file,
                          author: mePeer,
                          date: "2023-09-01T15:57:54+0000",
                          feedId: "idofafeed",
                          teamName: "Name of a Team")
        Log("made msg from local file")
        return msg
    }
  
    var body: some Scene {
        WindowGroup {
          ContentView(audioConfigHelper: self.$configurator,
                      audioConductor: self.$conductor,
                      isPlaying: self.$isPlaying,
                      msg: self.$msg)
        }
    }
}
