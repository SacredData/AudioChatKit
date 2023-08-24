//
//  AudioEngineManager.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import AudioKit
import AVFoundation


/// The purpose of this class is to instantiate the main AudioEngine of the app
/// and facilitate the necessary node connections to produce our overall
/// app signal flow. It will play host to the playback and recording managers,
/// in addition to facilitating necessary changes in session configuration, node
/// properties, and session interruptions.
class AudioEngineManager: ObservableObject, HasAudioEngine {
    private var playback: PlaybackManager = .shared

    let player: AudioPlayer
    let engine: AudioEngine = AudioEngine()
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    private init() {
        player = playback.player
    }
}
