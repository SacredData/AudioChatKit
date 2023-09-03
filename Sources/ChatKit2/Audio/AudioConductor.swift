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
    public let recordMan: RecordingManager = RecordingManager()
    public let whisperMan: Whisperer = Whisperer()

    public let engine: AudioEngine
    let session: AVAudioSession
    public var outputTap: RawDataTap
    
    public init() {
        engine = engineMan.engine
        session = engineMan.session

        engine.output = playerMan.player
        do {
            if !engine.avEngine.isRunning {
                try engine.start()
                Log(engine.avEngine.isRunning)
            }
        } catch {
            Log(error)
        }

        Log(engine.connectionTreeDescription)

        outputTap = playerMan.setupOutputTap(inputNode: playerMan.player)
        outputTap.start()
    }
}
