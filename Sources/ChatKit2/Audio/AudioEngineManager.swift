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
    public let player: AudioPlayer
    public let engine: AudioEngine
    public var recorder: NodeRecorder?
    public var inputNode: AudioEngine.InputNode?
    public var recEngine: AudioEngine?
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    let outputMixer: AVAudioMixerNode

    var eqLow: ParametricEQ?
    var eqLowMid: ParametricEQ?
    var eqMid: ParametricEQ?
    var eqHigh: ParametricEQ?
    
    var fastCompressor: Compressor?
    var slowCompressor: Compressor?
    var limiter: PeakLimiter?

    public init() {
        engine = AudioEngine()
        player = AudioPlayer()
        outputMixer = player.mixerNode
        setupOutputMixing(node: player)
    }

    private func setupOutputMixing(node: Node) {
        eqLow = ParametricEQ(node, centerFreq: 150, q: 0.1, gain: 1)
        eqLowMid = ParametricEQ(eqLow!, centerFreq: 800, q: 5, gain: -3.5)
        eqMid = ParametricEQ(eqLowMid!, centerFreq: 4000, q: 5, gain: 1.5)
        eqHigh = ParametricEQ(eqMid!, centerFreq: 10000, q: 0.2, gain: 0.5)
        fastCompressor = Compressor(eqHigh!, threshold: -15.0, headRoom:5.0, attackTime: 0.001, releaseTime: 0.15, masterGain: 1.0)
        slowCompressor = Compressor(fastCompressor!, threshold: -25.0, headRoom:5.0, attackTime: 0.12, releaseTime: 0.4, masterGain: 1.0)
        limiter = PeakLimiter(slowCompressor!, attackTime: 0.1, decayTime: 0.5, preGain: 2.0)
    }

    private func instantiateInput(eng: AudioEngine) throws -> AudioEngine.InputNode {
        Log("Requesting default audio engine input")
        IOSNowPlayableBehavior().handleNowPlayableSessionEnd()
        try session.setCategory(.playAndRecord, mode: .default)
        let hasValidPrefs = AudioConfigHelper().validateAudioSessionPreferences(audioSession: session)
        Log(hasValidPrefs)
        guard let input = eng.input else { fatalError("No input found") }
        Log("Got the InputNode")
        Log(input)
        Log(eng.inputDevice)
        return input
    }

    public func setupRecorder() throws {
        recEngine = AudioEngine()
        let input = try instantiateInput(eng: recEngine!)
        let recMixer = Mixer([input])
        inputNode = input
        recorder = try NodeRecorder(node: input, shouldCleanupRecordings: true) { floats, time in
            Log(floats, time)
            AudioCalculations().updateDbArray(floats)
        }
        /*
        recEngine.output = recMixer
        try recEngine.start()
        Log(recMixer.connections)
        Log(recEngine.connectionTreeDescription)
        try recorder?.record()
        */
    }
}
