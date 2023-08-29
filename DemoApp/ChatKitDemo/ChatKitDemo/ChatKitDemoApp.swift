//
//  ChatKitDemoApp.swift
//  ChatKitDemo
//
//  Created by Andrew Grathwohl on 8/29/23.
//

import AudioKit
import ChatKit2
import SwiftUI

@main
struct ChatKitDemoApp: App {
  @State var configurator: AudioConfigHelper = .init()
  @State var isPlaying: Bool = false
  @State var conductor: AudioConductor = .shared

  var engine: AudioEngine?
  var player: AudioPlayer?
  var preferredLocalization: String = ""
  
    init() {
      Log(configurator.sessionPreferencesAreValid)
        preferredLocalization = configurator.preferredLocalization ?? "blah"
        Log(preferredLocalization)
        
        engine = conductor.engine
        player = conductor.playerMan.player
    }
  
    var body: some Scene {
        WindowGroup {
          ContentView(audioConfigHelper: self.$configurator,
                      isPlaying: self.$isPlaying,
                      text: .constant("Hi Tyler")) // .constant() allows for init of pass by reference for a staticly defined value
                                                   // note: values set this way can not be modified
        }
    }
}
