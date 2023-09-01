//
//  AudioConfig.swift
//  
//  To be run at the very beginning of app launch
//
//  Created by Andrew Grathwohl on 8/23/23.
//

import AudioKit
import AVFoundation
import SwiftUI

public class AudioConfigHelper: ObservableObject {
    static var shared: AudioConfigHelper = AudioConfigHelper()
    public let downloadMan: MessageDownloader = .shared
    public var sessionPreferencesAreValid: Bool?
    public var preferredLocalization: String?

    public let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    public let recordFormat: AVAudioFormat
    public let playbackFormat: AVAudioFormat
    public var playbackFormatIsValid: Bool?
    public var recordingFormatIsValid: Bool?

    public init() {
        recordFormat = AudioFormats.record!
        playbackFormat = AudioFormats.global!
        initializeAudioKit()
        do {
            try setupDefaultSession()
        } catch {
            Log(error)
        }
        preferredLocalization = Bundle.main.preferredLocalizations.first
        validateAudioFormatForPlayback(audioFormat: playbackFormat)
        validateAudioFormatForRecording(audioFormat: recordFormat)
    }
    
    public func setRecordSession() throws {
        try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
    }
    
    public func validateAudioFormatForRecording(audioFormat: AVAudioFormat) {
        let isValidSampleRate = audioFormat.sampleRate == AudioFormats.record?.sampleRate
        let isValidChannelCount = audioFormat.channelCount == AudioFormats.record?.channelCount
        let isValidBitDepth = audioFormat.commonFormat == AudioFormats.record?.commonFormat
        recordingFormatIsValid = [isValidSampleRate, isValidChannelCount, isValidBitDepth].allSatisfy({$0 == true})
    }
    
    public func validateAudioFormatForPlayback(audioFormat: AVAudioFormat) {
        let isValidSampleRate = audioFormat.sampleRate == AudioFormats.global?.sampleRate
        let isValidChannelCount = audioFormat.channelCount == AudioFormats.global?.channelCount
        let isValidBitDepth = audioFormat.commonFormat == AudioFormats.global?.commonFormat
        playbackFormatIsValid = [isValidSampleRate, isValidChannelCount, isValidBitDepth].allSatisfy({$0 == true})
    }
    
    public func validateAudioSessionPreferences(audioSession: AVAudioSession) -> Bool {
        let prefersCorrectSampleRate = audioSession.preferredSampleRate == AudioFormats.global?.sampleRate
        Log(prefersCorrectSampleRate)
        let prefersCorrectInputChannels = audioSession.preferredInputNumberOfChannels == AudioFormats.record!.channelCount
        Log(prefersCorrectInputChannels, audioSession.preferredInputNumberOfChannels)
        let prefersCorrectOutputChannels = audioSession.preferredOutputNumberOfChannels == AudioFormats.global!.channelCount
        Log(prefersCorrectOutputChannels, audioSession.preferredOutputNumberOfChannels)
        return [prefersCorrectSampleRate, prefersCorrectInputChannels, prefersCorrectOutputChannels].allSatisfy({$0 == true})
    }
    
    public func validatePlaybackSessionCategory(audioSession: AVAudioSession) -> Bool {
        let hasPlaybackCategory = audioSession.category == .playback
        let hasSpokenAudioMode = audioSession.mode == .spokenAudio
        let hasLongAudioRoute = audioSession.routeSharingPolicy == .longFormAudio
        return [hasPlaybackCategory, hasSpokenAudioMode, hasLongAudioRoute].allSatisfy({$0 == true})
    }
    
    private func initializeAudioKit() {
        var formatSettings = AudioKit.Settings.audioFormat.settings
        formatSettings[AVSampleRateKey] = 48000
        formatSettings[AVLinearPCMBitDepthKey] = 32
        formatSettings[AVLinearPCMIsFloatKey] = true
        formatSettings[AVNumberOfChannelsKey] = 1
        
        AudioKit.Settings.enableLogging = true
        AudioKit.Settings.bufferLength = .short
        AudioKit.Settings.fixTruncatedRecordings = true
        AudioKit.Settings.disableAVAudioSessionCategoryManagement = false
        AudioKit.Settings.audioFormat = AVAudioFormat(settings: formatSettings)!
    }
    
    /// Default config for audio session will be long-form spoken audio playback
    public func setupDefaultSession() throws {
        try audioSession.setCategory(.playback, mode: .spokenAudio, policy: .longFormAudio)
    }
}
