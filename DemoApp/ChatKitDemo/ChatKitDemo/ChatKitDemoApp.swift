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
  
    init() {
        Log(configurator.sessionPreferencesAreValid)
        Log(preferredLocalization)
        Log(conductor)
        Log(conductor.engine)
        Log(conductor.playerMan.player)
        Log(conductor.recordMan)
    }
  
    var body: some Scene {
        WindowGroup {
          ContentView(audioConfigHelper: self.$configurator,
                      audioConductor: self.$conductor,
                      isPlaying: self.$isPlaying,
                      text: .constant(configurator.sessionPreferencesAreValid! ?
                                      "We good!" :
                                     "Nahhhhh")) // .constant() allows for init of pass by reference for a staticly defined value
                                                   // note: values set this way can not be modified
        }
    }
}
