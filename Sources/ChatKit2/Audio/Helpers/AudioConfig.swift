//
//  AudioConfig.swift
//  
//  To be run at the very beginning of app launch
//
//  Created by Andrew Grathwohl on 8/23/23.
//

import AudioKit
import AVFoundation

class AudioConfigHelper: ObservableObject {
    private init() {
        initializeAudioKit()
    }
    
    private func initializeAudioKit() {
        var formatSettings = AudioKit.Settings.audioFormat.settings
        formatSettings[AVSampleRateKey] = 48000
        formatSettings[AVLinearPCMBitDepthKey] = 32
        formatSettings[AVLinearPCMIsFloatKey] = true
        
        AudioKit.Settings.enableLogging = true
        AudioKit.Settings.bufferLength = .short
        AudioKit.Settings.fixTruncatedRecordings = true
        AudioKit.Settings.audioFormat = AVAudioFormat(settings: formatSettings)!
    }
    
    private func setupDefaultSession() {
        // TODO
    }
}
