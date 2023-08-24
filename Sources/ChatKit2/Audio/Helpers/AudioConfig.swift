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
    
    func validateAudioFormatForRecording(audioFormat: AVAudioFormat) -> Bool {
        let isValidSampleRate = audioFormat.sampleRate == AudioFormats.record?.sampleRate
        let isValidChannelCount = audioFormat.channelCount == AudioFormats.record?.channelCount
        let isValidBitDepth = audioFormat.commonFormat == AudioFormats.record?.commonFormat
        let isValidAudioFormat = [isValidSampleRate, isValidChannelCount, isValidBitDepth].allSatisfy({$0 == true})
        return isValidAudioFormat
    }
    
    func validateAudioFormatForPlayback(audioFormat: AVAudioFormat) -> Bool {
        let isValidSampleRate = audioFormat.sampleRate == AudioFormats.global?.sampleRate
        let isValidChannelCount = audioFormat.channelCount == AudioFormats.global?.channelCount
        let isValidBitDepth = audioFormat.commonFormat == AudioFormats.global?.commonFormat
        let isValidAudioFormat = [isValidSampleRate, isValidChannelCount, isValidBitDepth].allSatisfy({$0 == true})
        return isValidAudioFormat
    }
}
