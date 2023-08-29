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
    let configurator: AudioConfigHelper
    /*let conductor: AudioConductor
    let engine: AudioEngine
    let player: AudioPlayer*/
    let preferredLocalization: String
    init() {
        configurator = AudioConfigHelper()
        Log(configurator.sessionPreferencesAreValid)
        preferredLocalization = configurator.preferredLocalization!
        Log(preferredLocalization)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
