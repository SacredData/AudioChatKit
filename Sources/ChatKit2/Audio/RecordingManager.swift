//
//  RecordingManager.swift
//  
//
//  Created by Andrew Grathwohl on 8/29/23.
//

import AudioKit
import AVFoundation

public class RecordingManager: ObservableObject, HasAudioEngine {
    private var engineMan: AudioEngineManager = .shared
    private var audioConfig: AudioConfigHelper = .shared
    public var engine: AudioKit.AudioEngine
    public var inputNode: AudioEngine.InputNode?
    public var recorder: NodeRecorder?
    public var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    var durationAnchor: Double = 0.0
    var currentDuration: TimeInterval = 0.0
    @Published var durationString: String?
    @Published var hasRecordPermissions: Bool?
    
    public init() {
        engine = engineMan.engine
        //inputNode = engine.input
    }
    
    public func createRecorder() {
        do {
            if !engine.avEngine.isRunning {
                try engine.start()
                Log(engine.avEngine.isRunning)
            }
            if let i = engine.input {
                getPermissions()
                recorder = try NodeRecorder(node: i, shouldCleanupRecordings: true) { floats, time in
                    let timeSec = AVAudioTime.seconds(forHostTime: time.hostTime)
                    Log(timeSec)
                    if self.durationAnchor == 0.0 {
                        self.durationAnchor = timeSec
                    } else {
                        self.currentDuration = timeSec - self.durationAnchor
                    }
                    DispatchQueue.main.async {
                        self.durationString = TimeHelper().formatDuration(duration: self.currentDuration)
                        Log(self.durationString)
                    }
                }
                Log(recorder)
                try audioConfig.setRecordSession()
                try recorder!.record()
            }
        } catch {
            Log(error)
            return
        }
    }
    
    private func getPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasRecordPermissions = granted
            }
            if granted {
                Log("⏺️🎤 Recording permissions granted")
                // The user granted access. Present recording interface.
            } else {
                Log("❌🎤 Recording permissions denied")
                // Present message to user indicating that recording
                // can't be performed until they change their preference
                // under Settings -> Privacy -> Microphone
            }
        }
    }
}
