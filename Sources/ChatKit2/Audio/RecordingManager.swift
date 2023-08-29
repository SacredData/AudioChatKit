//
//  RecordingManager.swift
//  
//
//  Created by Andrew Grathwohl on 8/29/23.
//

import AudioKit
import AVFoundation

public class RecordingManager: ObservableObject {
    private var audioEngineManager: AudioEngineManager = .shared
    public var engine: AudioKit.AudioEngine
    public var recorder: NodeRecorder
    public var inputNode: AudioEngine.InputNode

    public init() {
        do {
            try audioEngineManager.setupRecorder()
        } catch {
            Log(error)
        }
        if let e = audioEngineManager.recEngine,
           let i = audioEngineManager.inputNode,
           let r = audioEngineManager.recorder {
            engine = e
            inputNode = i
            recorder = r
        } else {
            engine = AudioEngine()
            inputNode = engine.input!
            recorder = try! NodeRecorder(node: inputNode)
        }
    }
}
