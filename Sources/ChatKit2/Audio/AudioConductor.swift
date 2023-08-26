//
//  AudioConductor.swift
//  
//
//  Created by Andrew Grathwohl on 8/26/23.
//

import AudioKit
import AVFoundation

public class AudioConductor: ObservableObject {
    static var shared: AudioConductor = AudioConductor()
    let engineMan: AudioEngineManager = AudioEngineManager()
    let playerMan: PlaybackManager = PlaybackManager()
    
    let engine: AudioEngine
    let player: AudioPlayer
    let session: AVAudioSession
    let mixer: Mixer = Mixer()
    
    public init() {
        engine = engineMan.engine
        session = engineMan.session
        player = playerMan.player
        
        mixer.addInput(player)
        engine.output = mixer
        Log(engine.connectionTreeDescription)
    }
}
