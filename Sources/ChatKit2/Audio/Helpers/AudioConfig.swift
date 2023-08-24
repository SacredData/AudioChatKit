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
    var sessionPreferencesAreValid: Bool?
    var recordingFormatIsValid: Bool?
    var playbackFormatIsValid: Bool?

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
    
    /// Default config for audio session will be long-form spoken audio playback
    private func setupDefaultSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .spokenAudio, policy: .longFormAudio)
        sessionPreferencesAreValid = validateAudioSessionPreferences(audioSession: audioSession)
    }
    
    func validateAudioFormatForRecording(audioFormat: AVAudioFormat) {
        let isValidSampleRate = audioFormat.sampleRate == AudioFormats.record?.sampleRate
        let isValidChannelCount = audioFormat.channelCount == AudioFormats.record?.channelCount
        let isValidBitDepth = audioFormat.commonFormat == AudioFormats.record?.commonFormat
        recordingFormatIsValid = [isValidSampleRate, isValidChannelCount, isValidBitDepth].allSatisfy({$0 == true})
    }
    
    func validateAudioFormatForPlayback(audioFormat: AVAudioFormat) {
        let isValidSampleRate = audioFormat.sampleRate == AudioFormats.global?.sampleRate
        let isValidChannelCount = audioFormat.channelCount == AudioFormats.global?.channelCount
        let isValidBitDepth = audioFormat.commonFormat == AudioFormats.global?.commonFormat
        playbackFormatIsValid = [isValidSampleRate, isValidChannelCount, isValidBitDepth].allSatisfy({$0 == true})
    }
    
    func validateAudioSessionPreferences(audioSession: AVAudioSession) -> Bool {
        let prefersCorrectSampleRate = audioSession.preferredSampleRate == AudioFormats.global?.sampleRate
        let prefersCorrectInputChannels = audioSession.preferredInputNumberOfChannels == AudioFormats.record!.channelCount
        let prefersCorrectOutputChannels = audioSession.preferredOutputNumberOfChannels == AudioFormats.global!.channelCount
        return [prefersCorrectSampleRate, prefersCorrectInputChannels].allSatisfy({$0 == true})
    }
}
