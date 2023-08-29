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
  
    /*let conductor: AudioConductor
    let engine: AudioEngine
    let player: AudioPlayer*/
  var preferredLocalization: String = ""
  
    init() {
//        configurator = AudioConfigHelper()
      Log(configurator.sessionPreferencesAreValid)
        preferredLocalization = configurator.preferredLocalization ?? "blah"
        Log(preferredLocalization)
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
