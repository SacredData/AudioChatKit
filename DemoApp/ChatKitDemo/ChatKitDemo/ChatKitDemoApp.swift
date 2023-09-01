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
  @State var conductor: AudioConductor = .shared
  @State var isPlaying: Bool = false
  var preferredLocalization: String = ""
  var downloadMan: MessageDownloader = .shared

    init() {
        conductor.start()
        Log(preferredLocalization)
        Log(conductor)
        Log(conductor.engine)
        Log(conductor.playerMan.player)
    }

    var body: some Scene {
        WindowGroup {
          ContentView(audioConfigHelper: self.$configurator,
                      audioConductor: self.$conductor,
                      isPlaying: self.$isPlaying)
        }
    }
}
