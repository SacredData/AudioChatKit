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
public class AudioEngineManager: ObservableObject, HasAudioEngine {
    static var shared: AudioEngineManager = AudioEngineManager()

    private var audioConfig: AudioConfigHelper = .shared
    private var playback: PlaybackManager = .shared

    let player: AudioPlayer
    public let engine: AudioEngine
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    let outputMixer: AVAudioMixerNode

    public init() {
        engine = AudioEngine()
        Log(engine)
        player = playback.player
        Log(player)
        outputMixer = player.mixerNode
        setupOutputMixing(node: player)
        Log(engine.connectionTreeDescription)
    }

    private func setupOutputMixing(node: Node) {
        let eqLow = ParametricEQ(node, centerFreq: 150, q: 0.1, gain: 1)
        let eqLowMid = ParametricEQ(eqLow, centerFreq: 800, q: 5, gain: -3.5)
        let eqMid = ParametricEQ(eqLowMid, centerFreq: 4000, q: 5, gain: 1.5)
        let eqHigh = ParametricEQ(eqMid, centerFreq: 10000, q: 0.2, gain: 0.5)
        let fastCompressor = Compressor(eqHigh, threshold: -15.0, headRoom:5.0, attackTime: 0.001, releaseTime: 0.15, masterGain: 1.0)
        let slowCompressor = Compressor(fastCompressor, threshold: -25.0, headRoom:5.0, attackTime: 0.12, releaseTime: 0.4, masterGain: 1.0)
        _ = PeakLimiter(slowCompressor, attackTime: 0.1, decayTime: 0.5, preGain: 2.0)
    }
    
    private func instantiateInput() {
        Log("Requesting default audio engine input")
        guard let input = engine.input else { return }
        Log("Got the InputNode")
        Log(input)
    }
}
