//
//  AudioConductor.swift
//  
//
//  Created by Andrew Grathwohl on 8/26/23.
//

import AudioKit
import AVFoundation

public class AudioConductor: ObservableObject, HasAudioEngine {
    public static var shared: AudioConductor = AudioConductor()
    public let engineMan: AudioEngineManager = .shared
    public let playerMan: PlaybackManager = PlaybackManager()

    public let engine: AudioEngine
    let player: AudioPlayer
    let session: AVAudioSession
    var outputTap: RawDataTap
    
    public init() {
        engine = engineMan.engine
        session = engineMan.session
        player = playerMan.player

        engine.output = player
        do {
            try engine.start()
        } catch {
            Log(error)
        }

        Log(engine.connectionTreeDescription)

        outputTap = playerMan.setupOutputTap(inputNode: player)
        outputTap.start()
    }
}
