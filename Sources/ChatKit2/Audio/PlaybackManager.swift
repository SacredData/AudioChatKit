//
//  PlaybackManager.swift
//
//  Created by Andrew Grathwohl on 8/21/23.
//

import AudioKit
import AVFoundation
import MediaPlayer

public class PlaybackManager: ObservableObject, ProcessesPlayerInput {
    private var audioConfig: AudioConfigHelper = .shared
    private var audioEngineManager: AudioEngineManager = .shared
    public let audioCalc: AudioCalculations = .shared
    public var engine: AudioKit.AudioEngine
    public var player: AudioKit.AudioPlayer

    var session: AVAudioSession

    var nowPlayable: Bool = false
    var remoteCommands: [NowPlayableCommand] = []
    
    var tapStartTime: AVAudioTime?
    var playackTime: TimeInterval?

    /// Use this published value to update UI progress bar
    @Published var currentProgress: Float?
    var currentTime: TimeInterval? {
        didSet {
            currentTimeString = TimeHelper().formatDuration(duration: currentTime!)
        }
    }
    @Published var currentTimeString: String?
    var currentFile: [String: AVAudioFile]?
    @Published var nowPlayableMessage: Message?
    var currentStatus: NodeStatus.Playback? {
        get {
            return player.status
        }
    }
    var sampleStartTime: AVAudioTime?
    var playbackState: PlaybackState = .isInitializing {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                switch self.playbackState {
                case .isBuffering:
                    self.playMessage()
                case .isPaused:
                    // Do not end the playback session but be able to be interrupted
                    if self.player.status != .paused {
                        self.player.pause()
                    }
                    if let npmsg = self.nowPlayableMessage {
                        npmsg.newPlaybackEvent(
                            events: [PlaybackEvents.pause(Date(), self.player.currentTime)])
                    }
                case .isStopped:
                    // Explicitly stopping the player timeline means we end session
                    if self.player.status != .stopped {
                        self.player.stop()
                    }
                    if let npmsg = self.nowPlayableMessage {
                        npmsg.newPlaybackEvent(
                            events: [PlaybackEvents.stop(Date(), self.player.currentTime)])
                    }
                    self.endPlaybackSession()
                case .isReady:
                    // Set this to indicate we can/should play
                    // DO NOT use .isPlaying
                    if !self.player.isPlaying {
                        self.playMessage()
                    }
                case .isPlaying:
                    self.tapStartTime = AVAudioTime.now()
                    if let file = self.player.file {
                        // Our anchor AVAudioTime to use for tracking timeline progress
                        self.sampleStartTime = TimeHelper().audioSampleTime(audioFile: file)
                        // Set the class's currentFile to what player has loaded
                        self.currentFile = [self.getUploadIdFromFile(file: file): file]

                        if let npmsg = self.nowPlayableMessage {
                            if npmsg.audioFile == file {
                                npmsg.newPlaybackEvent(events: [PlaybackEvents.play(Date())])
                                self.changeNowPlayingItem(msg: npmsg)
                            }
                        }
                    }
                default:
                    Log(self.playbackState, self.player.status)
                    break
                }
            }
        }
    }
    
    // The pending audio messages to play when player is freed up
    var messageQueue: [Message] = []
    var messageCompletions: [Message] = []

    public init() {
        // Ensure we get AudioKit settings
        // Check the AudioKit settings and modify them if needed
        player = audioEngineManager.player
        engine = audioEngineManager.engine
        session = audioEngineManager.session
        playbackState = PlaybackState.isWaiting
        
        let playbackCompletionHandler = {
            if let npmsg = self.nowPlayableMessage {
                npmsg.newPlaybackEvent(events: [PlaybackEvents.completion(Date())])
            }
            self.tapStartTime = nil
            self.currentProgress = 0.0
            let queuedMessages = self.messageQueue.count
            if queuedMessages > 0 {
                let nextMessage = self.messageQueue.removeFirst()
                self.playbackState = PlaybackState.isBuffering(nextMessage.audioFile)
            } else {
                // We ain't got nothin' so lets just sit there and wait
                self.playbackState = PlaybackState.isWaiting
            }
        }
        
        player.completionHandler = playbackCompletionHandler
        
        setupRemoteCommands()
    }
    
    /// Make the playback manager aware of a new `Message` and play or queue
    /// it immediately.
    public func newLocalMessage(msg: Message) throws {
        if player.isPlaying {
            messageQueue.append(msg)
        } else {
            try load(msg: msg)
        }
    }
    
    /// Immediately change player's loaded `Message` and play it
    public func load(msg: Message) throws {
        let shouldBuffer = msg.audioFile.duration > 30
        try player.load(file: msg.audioFile, buffered: shouldBuffer)
        if player.isBuffered || player.file == msg.audioFile {
            playbackState = PlaybackState.isReady(player.file)
            startPlaybackAudioEngine()
            DispatchQueue.main.async {
                self.nowPlayableMessage = msg
            }
        }
    }

    /// Seek the player to the given `TimeInterval` for currently-loaded message
    public func seek(to time: TimeInterval) {
        DispatchQueue.global(qos: .userInteractive).async {
            switch self.playbackState {
            case .isScheduling(let aVAudioFile),
                    .isBuffering(let aVAudioFile),
                    .isPaused(let aVAudioFile),
                    .isPlaying(let aVAudioFile),
                    .isReady(let aVAudioFile),
                    .isInterrupted(let aVAudioFile):
                // No matter what the clamped time will never be > audio duration
                let clampedTime = time.clamped(to: 0 ... aVAudioFile!.duration)
                self.player.seek(time: clampedTime)
            default:
                break
            }
        }
    }

    /// Creates an AudioKit `RawDataTap` responsible for incrementing playback
    /// progress. Updates `NowPlayingInfo` with current playback state and metadata.
    public func setupOutputTap(inputNode: Node) -> RawDataTap {
        return RawDataTap(inputNode, bufferSize: 4096, callbackQueue: DispatchQueue.init(label:"outputtap", qos: .userInitiated), handler: { floats in
            if self.tapStartTime != nil {
                self.updateNowPlayingProgress()
                //self.audioCalc.bufferFromFloatsStereo(floats: floats)
            }
        })
    }

    /// Override any scheduled playback events or current playback state, and
    /// immediately begin to play the currently-loaded `Message`.
    public func playMessage() {
        DispatchQueue.global(qos: .userInitiated).async {
            switch self.playbackState {
            case .isScheduling(let aVAudioFile),
                    .isBuffering(let aVAudioFile),
                    .isPaused(let aVAudioFile),
                    .isReady(let aVAudioFile):
                self.player.play()
                if self.player.isPlaying {
                    self.playbackState = PlaybackState.isPlaying(aVAudioFile)
                }
            default:
                break
            }
        }
    }
    
    public func pause() {
        if player.status == .playing {
            player.pause()
            if player.status == .paused {
                playbackState = PlaybackState.isPaused(player.file)
            }
        } else {
            return
        }
    }

    private func startPlaybackAudioEngine() {
        do {
            try engine.start()
            try configurePlaybackSession()
        } catch {
            Log(error)
            return
        }
    }
    
    private func configurePlaybackSession() throws {
        if !nowPlayable {
            try IOSNowPlayableBehavior().handleNowPlayableSessionStart()
        }
        nowPlayable = true
    }
    
    private func endPlaybackSession() {
        IOSNowPlayableBehavior().handleNowPlayableSessionEnd()
        nowPlayable = false
    }
    
    private func getUploadIdFromFile(file: AVAudioFile) -> String {
        return file.url.lastPathComponent.replacingOccurrences(of: ".caf", with: "")
    }

    private func changeNowPlayingItem(msg: Message) {
        // TODO: Make the msg arg optional and when not provided we should use
        // self.nowPlayableMessage by default. Catch and log error when that
        // is not defined...
        IOSNowPlayableBehavior().handleNowPlayableItemChange(metadata: msg.staticMetadata)
    }
    
    private func updateNowPlayingProgress() {
        var isPlayingNow = false
        switch playbackState {
        case .isPlaying:
            isPlayingNow = true
        default:
            break
        }
        if isPlayingNow {
            DispatchQueue.main.async {
                // Publish new progress float for UI to grab
                self.currentProgress = Float(self.player.currentPosition)
                self.currentTime = self.player.currentTime
                Log(self.currentProgress, self.currentTime)
            }
            if nowPlayableMessage?.transcript != nil {
                let currentLO = nowPlayableMessage!.transcript?.languageOption
                let loGroup = MPNowPlayingInfoLanguageOptionGroup.init(languageOptions: [currentLO!], defaultLanguageOption: currentLO, allowEmptySelection: true)
                
                IOSNowPlayableBehavior().handleNowPlayablePlaybackChange(
                    playing: isPlayingNow,
                    metadata: NowPlayableDynamicMetadata(rate: player.playerNode.rate, position: Float(player.currentPosition), duration: Float(player.duration), currentLanguageOptions: [currentLO!], availableLanguageOptionGroups: [loGroup]))
            }
        }
    }
    
    private func setupRemoteCommands() {
        NowPlayableCommand.pause.remoteCommand.addTarget { event in
            if !self.nowPlayable {
                Log("remote pause command failed: no nowplayable item")
                return .noActionableNowPlayingItem
            }
            if self.player.status == NodeStatus.Playback.paused {
                Log("remote pause command failed: already paused")
                return .commandFailed
            }
            self.pause()
            return .success
        }
        remoteCommands.append(NowPlayableCommand.pause)
        
        NowPlayableCommand.play.remoteCommand.addTarget { event in
            if !self.nowPlayable {
                Log("remote play command failed: no nowplayable item")
                return .noActionableNowPlayingItem
            }
            if self.player.status == NodeStatus.Playback.playing {
                Log("remote play command failed: already playing")
                return .commandFailed
            }
            self.playMessage()
            return .success
        }
        remoteCommands.append(NowPlayableCommand.play)
        
        NowPlayableCommand.stop.remoteCommand.addTarget { event in
            if !self.nowPlayable {
                Log("remote stop command failed: no nowplayable item")
                return .noActionableNowPlayingItem
            }
            if self.player.status == NodeStatus.Playback.stopped {
                Log("remote stop command failed: already stopped")
                return .commandFailed
            }
            self.player.stop()
            if self.player.status != NodeStatus.Playback.stopped {
                return .commandFailed
            }
            self.playbackState = PlaybackState.isStopped
            return .success
        }
        remoteCommands.append(NowPlayableCommand.stop)
        
        NowPlayableCommand.changePlaybackPosition.remoteCommand.addTarget { event in
            if !self.nowPlayable {
                Log("remote seek command failed: no nowplayable item")
                return .noActionableNowPlayingItem
            }
            if event.timestamp > self.player.duration || event.timestamp < 0.0 {
                Log("remote seek command failed: invalid seek time provided")
                return .commandFailed
            }
            self.seek(to: event.timestamp)
            return .success
        }
        remoteCommands.append(NowPlayableCommand.changePlaybackPosition)

        Log(remoteCommands)
    }
    
    private func bufferFromFloats(floats: [Float]) throws {
        var f: [Float] = []
        f.append(contentsOf: floats)

        f.withUnsafeMutableBufferPointer { bytes in
            let ab = AudioBuffer(
                mNumberChannels: 1,
                mDataByteSize: UInt32(bytes.count * MemoryLayout<Float>.size),
                mData: bytes.baseAddress)
            var bl = AudioBufferList(mNumberBuffers: 1, mBuffers: ab)
            let ob = AVAudioPCMBuffer(pcmFormat: player.outputFormat, bufferListNoCopy: &bl)!
            Log(ob.frameLength)
            Log(ob.floatChannelData)
            let pk = audioCalc.getPeak(audioBuffer: ob)
            Log(pk)
        }
    }
}

/// Enables TimeInterval value to be clamped from 0 ... duration of message
private extension Comparable {
    dynamic func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
