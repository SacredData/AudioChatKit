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
    init() {
        let configurator = AudioConfigHelper()
        Log(configurator.sessionPreferencesAreValid)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
