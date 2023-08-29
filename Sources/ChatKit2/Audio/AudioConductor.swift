//
//  AudioConductor.swift
//  
//
//  Created by Andrew Grathwohl on 8/26/23.
//

import AudioKit
import AVFoundation

public class AudioConductor: ObservableObject, HasAudioEngine {
    static var shared: AudioConductor = AudioConductor()
    public let engineMan: AudioEngineManager = AudioEngineManager()
    public let playerMan: PlaybackManager = PlaybackManager()
    public let recordMan: RecordingManager = RecordingManager()
    public let audioCalc: AudioCalculations = AudioCalculations()
    
    public let engine: AudioEngine
    let player: AudioPlayer
    let session: AVAudioSession
    let mixer: Mixer = Mixer()
    var outputTap: RawDataTap
    
    public init() {
        engine = engineMan.engine
        session = engineMan.session
        player = playerMan.player

        engine.output = player
        Log(engine.connectionTreeDescription)

        outputTap = playerMan.setupOutputTap(inputNode: player)
        outputTap.start()
    }
}
