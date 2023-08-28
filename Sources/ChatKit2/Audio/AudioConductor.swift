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
    
    public let engine: AudioEngine
    let player: AudioPlayer
    let session: AVAudioSession
    let mixer: Mixer = Mixer()
    
    public init() {
        engine = engineMan.engine
        session = engineMan.session
        player = playerMan.player
        
        //mixer.addInput(player)
        engine.output = player
        Log(engine.connectionTreeDescription)
    }
}
