//
//  HandsFreeManager.swift
//  storyboard-v2
//
//  Created by Andrew Grathwohl on 8/21/23.
//

import AudioKit
import AVFoundation
import MediaPlayer

class PlaybackManager: ObservableObject, ProcessesPlayerInput, HasAudioEngine {
    private var audioEngineManager: AudioEngineManager = .shared
    static var shared: PlaybackManager = PlaybackManager()
    
    var engine: AudioKit.AudioEngine
    var mixer: AudioKit.Mixer
    var player: AudioKit.AudioPlayer
    var session: AVAudioSession
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
    var nowPlayableMessage: Message?
    var currentStatus: NodeStatus.Playback? {
        get {
            return player.status
        }
    }
    var sampleStartTime: AVAudioTime?
    var playbackState: PlaybackState = .isInitializing {
        didSet {
            // TODO: Handle changes in playback state
            switch playbackState {
            case .isPaused:
                // Do not end the playback session but be able to be interrupted
                if player.status != .paused {
                    player.pause()
                }
            case .isStopped:
                // Explicitly stopping the player timeline means we end session
                if player.status != .stopped {
                    player.stop()
                }
                endPlaybackSession()
            case .isReady:
                // Set this to indicate we can/should play
                // DO NOT use .isPlaying
                playMessage()
            case .isPlaying:
                if let file = player.file {
                    // Our anchor AVAudioTime to use for tracking timeline progress
                    sampleStartTime = TimeHelper().audioSampleTime(audioFile: file)
                    // Set the class's currentFile to what player has loaded
                    currentFile = [getUploadIdFromFile(file: file): file]

                    if let npmsg = nowPlayableMessage {
                        if npmsg.audioFile == file {
                            changeNowPlayingItem(msg: npmsg)
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    // The pending audio messages to play when player is freed up
    var messageQueue: [Message] = []
    var messageCompletions: [Message] = []
    
    private init() {
        // Ensure we get AudioKit settings
        // Check the AudioKit settings and modify them if needed
        player = AudioPlayer()
        mixer = Mixer()
        engine = audioEngineManager.engine
        session = audioEngineManager.session
        
        mixer.addInput(player)
        engine.output = mixer
        
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

        // TODO: Finish the player tap and increment time elapsed in handler
        _ = RawDataTap2.init(player, handler: {floats in
            Log(floats)
            self.updateNowPlayingProgress()
        })
    }
    
    func newLocalMessage(msg: Message) throws {
        let shouldBuffer = msg.audioFile.duration > 30
        if player.isPlaying {
            messageQueue.append(msg)
        } else {
            startPlaybackAudioEngine()
            try player.load(file: msg.audioFile, buffered: shouldBuffer)
            if player.isBuffered || player.file == msg.audioFile {
                playbackState = PlaybackState.isReady(player.file)
                nowPlayableMessage = msg
            }
        }
    }
    
    func seek(to time: TimeInterval) {
        switch playbackState {
        case .isScheduling(let aVAudioFile),
                .isBuffering(let aVAudioFile),
                .isPaused(let aVAudioFile),
                .isPlaying(let aVAudioFile),
                .isReady(let aVAudioFile),
                .isInterrupted(let aVAudioFile):
            // No matter what the clamped time will never be > audio duration
            let clampedTime = time.clamped(to: 0 ... aVAudioFile!.duration)
            player.seek(time: clampedTime)
        default:
            break
        }
    }
    
    private func playMessage() {
        switch playbackState {
        case .isScheduling(let aVAudioFile),
                .isBuffering(let aVAudioFile),
                .isPaused(let aVAudioFile),
                .isStopped(let aVAudioFile),
                .isReady(let aVAudioFile):
            player.play()
            if player.isPlaying {
                playbackState = PlaybackState.isPlaying(aVAudioFile)
            }
        default:
            break
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
        try IOSNowPlayableBehavior().handleNowPlayableSessionStart()
    }
    
    private func endPlaybackSession() {
        IOSNowPlayableBehavior().handleNowPlayableSessionEnd()
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
        let currentLO = nowPlayableMessage!.transcript?.languageOption
        let loGroup = MPNowPlayingInfoLanguageOptionGroup.init(languageOptions: [currentLO!], defaultLanguageOption: currentLO, allowEmptySelection: true)
        IOSNowPlayableBehavior().handleNowPlayablePlaybackChange(
            playing: isPlayingNow,
            metadata: NowPlayableDynamicMetadata(rate: player.playerNode.rate, position: Float(player.currentPosition), duration: Float(player.duration), currentLanguageOptions: [currentLO!], availableLanguageOptionGroups: [loGroup]))
    }
}

/// Enables TimeInterval value to be clamped from 0 ... duration of message
private extension Comparable {
    dynamic func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
