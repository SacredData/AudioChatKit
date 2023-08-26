//
//  PlaybackManager.swift
//  storyboard-v2
//
//  Created by Andrew Grathwohl on 8/21/23.
//

import AudioKit
import AVFoundation
import MediaPlayer

public class PlaybackManager: ObservableObject, ProcessesPlayerInput {
    private var audioConfig: AudioConfigHelper = .shared
    private var audioEngineManager: AudioEngineManager = .shared
    public var engine: AudioKit.AudioEngine
    public var player: AudioKit.AudioPlayer

    var session: AVAudioSession

    var nowPlayable: Bool = false

    /// Use this published value to update UI progress bar
    @Published var currentProgress: Float?
    var currentTime: TimeInterval? {
        get {
            return player.currentTime
        }
    }
    var currentTimeString: String? {
        get {
            return TimeHelper().formatDuration(duration: currentTime ?? 0.0)
        }
    }
    var currentPosition: Double? {
        get {
            return player.currentPosition
        }
    }
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
                case .isPaused:
                    // Do not end the playback session but be able to be interrupted
                    if self.player.status != .paused {
                        self.player.pause()
                    }
                case .isStopped:
                    // Explicitly stopping the player timeline means we end session
                    if self.player.status != .stopped {
                        self.player.stop()
                    }
                    self.endPlaybackSession()
                case .isReady:
                    // Set this to indicate we can/should play
                    // DO NOT use .isPlaying
                    self.playMessage()
                case .isPlaying:
                    if let file = self.player.file {
                        // Our anchor AVAudioTime to use for tracking timeline progress
                        self.sampleStartTime = TimeHelper().audioSampleTime(audioFile: file)
                        // Set the class's currentFile to what player has loaded
                        self.currentFile = [self.getUploadIdFromFile(file: file): file]

                        if let npmsg = self.nowPlayableMessage {
                            if npmsg.audioFile == file {
                                self.changeNowPlayingItem(msg: npmsg)
                            }
                        }
                    }
                default:
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
            let queuedMessages = self.messageQueue.count
            if queuedMessages > 0 {
                // We need to pop the next message from the queue and play
                let nextMessage = self.messageQueue.removeFirst()
                // TODO: React to this change in state and begin to load and buffer the message
                self.playbackState = PlaybackState.isBuffering(nextMessage.audioFile)
            } else {
                // We ain't got nothin' so lets just sit there and wait
                self.playbackState = PlaybackState.isWaiting
            }
        }
        
        player.completionHandler = playbackCompletionHandler
    }
    
    public func newLocalMessage(msg: Message) throws {
        let shouldBuffer = msg.audioFile.duration > 30
        if player.isPlaying {
            messageQueue.append(msg)
        } else {
            try player.load(file: msg.audioFile, buffered: shouldBuffer)
            if player.isBuffered || player.file == msg.audioFile {
                playbackState = PlaybackState.isReady(player.file)
                startPlaybackAudioEngine()
                DispatchQueue.main.async {
                    self.nowPlayableMessage = msg
                }
            }
        }
    }
    
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
    
    private func playMessage() {
        DispatchQueue.global(qos: .userInitiated).async {
            switch self.playbackState {
            case .isScheduling(let aVAudioFile),
                    .isBuffering(let aVAudioFile),
                    .isPaused(let aVAudioFile),
                    .isStopped(let aVAudioFile),
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

    private func startPlaybackAudioEngine() {
        do {
            try configurePlaybackSession()
            if !engine.avEngine.isRunning {
                try engine.start()
            }
        } catch {
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
        IOSNowPlayableBehavior().handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata(
            assetURL: msg.audioFile.url,
            mediaType: .audio,
            isLiveStream: false,
            title: msg.title,
            artist: msg.author,
            artwork: nil,
            albumArtist: msg.author,
            albumTitle: msg.teamName))
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
            let currentLO = nowPlayableMessage!.transcript?.languageOption
            let loGroup = MPNowPlayingInfoLanguageOptionGroup.init(languageOptions: [currentLO!], defaultLanguageOption: currentLO, allowEmptySelection: true)
            IOSNowPlayableBehavior().handleNowPlayablePlaybackChange(
                playing: isPlayingNow,
                metadata: NowPlayableDynamicMetadata(rate: player.playerNode.rate, position: Float(player.currentPosition), duration: Float(player.duration), currentLanguageOptions: [currentLO!], availableLanguageOptionGroups: [loGroup]))
            DispatchQueue.main.async {
                // Publish new progress float for UI to grab
                self.currentProgress = Float(self.player.currentPosition)
            }
        }
    }
}

/// Enables TimeInterval value to be clamped from 0 ... duration of message
private extension Comparable {
    dynamic func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
