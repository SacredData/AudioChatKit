//
//  RecordingManager.swift
//  
//
//  Created by Andrew Grathwohl on 8/29/23.
//

import AudioKit
import AudioKitEX
import AVFoundation

public class RecordingManager: ObservableObject, HasAudioEngine {
    //private var engineMan: AudioEngineManager = .shared
    private var audioConfig: AudioConfigHelper = .shared
    public var audioCalcs: AudioCalculations = .shared
    private var encodingMan: EncodingManager = EncodingManager()
    public var engine: AudioKit.AudioEngine
    public var inputNode: AudioEngine.InputNode?
    public var recorder: NodeRecorder?
    public var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    var durationAnchor: Double = 0.0
    var currentDuration: TimeInterval = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.durationString = TimeHelper().formatDuration(duration: self.currentDuration)
            }
        }
    }
    @Published public var durationString: String? {
        didSet {
            Log(durationString)
        }
    }
    @Published var hasRecordPermissions: Bool?
    
    public init() {
        Log(AudioKit.Settings.audioFormat)
        Log(AudioKit.Settings.defaultAudioFormat)
        Log(AudioKit.Settings.channelCount)
        Log(AudioKit.Settings.sampleRate)
        Log(AudioKit.Settings.recordingBufferLength)

        engine = AudioEngine()
    }
    
    public func createRecorder() {
        do {
            try audioConfig.setRecordSession()
            let inputPorts = getInputPorts()
            Log("Session reported available inputs")
            Log(inputPorts)
            if let i = engine.input {
                inputNode = i
                getPermissions()
                let silencer = Fader(inputNode!, gain: 0)
                let mixer = Mixer([silencer])
                engine.output = mixer
                if !engine.avEngine.isRunning {
                    try engine.start()
                    Log(engine.avEngine.isRunning)
                }
                recorder = try NodeRecorder(node: i, shouldCleanupRecordings: true) { floats, time in
                    DispatchQueue.global(qos: .userInteractive).async {
                        self.audioCalcs.updateDbArray(floats)
                    }
                    let timeSec = AVAudioTime.seconds(forHostTime: time.hostTime)
                    if self.durationAnchor == 0.0 {
                        self.durationAnchor = timeSec
                    } else {
                        self.currentDuration = timeSec - self.durationAnchor
                    }
                    // TODO: Route buffer output to opus encoder!
                    /*
                    DispatchQueue.global(qos: .utility).async {
                        self.audioCalcs.bufferFromFloats(floats: floats)
                        Log(self.audioCalcs.pcmOutputBufferMono)
                    }
                    */
                }
                Log(recorder)
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
    
    private func getInputPorts() -> [Any] {
        var avail: [AVAudioSessionPortDescription] = []
        guard let availableInputs = audioSession.availableInputs else { return [] }
        if availableInputs.count > 0 {
            avail.append(contentsOf: availableInputs)
        }
        return avail
    }
}
