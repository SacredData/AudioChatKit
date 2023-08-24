//
//  HandsFreeManager.swift
//  storyboard-v2
//
//  Created by Andrew Grathwohl on 8/21/23.
//

import AudioKit
import AVFoundation

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
    var currentMessage: [String: AVAudioFile]?
    var currentStatus: NodeStatus.Playback? {
        get {
            return player.status
        }
    }
    var playbackState: PlaybackState {
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
                    // Set the class's currentMessage to what player has loaded
                    currentMessage = [getUploadIdFromFile(file: file): file]
                }
            default:
                break
            }
        }
    }
    
    // The pending audio messages to play when player is freed up
    var messageQueue: [AVAudioFile] = []
    
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
                self.playbackState = PlaybackState.isBuffering(nextMessage)
            } else {
                // We ain't got nothin' so lets just sit there and wait
                self.playbackState = PlaybackState.isWaiting
            }
        }
        
        player.completionHandler = playbackCompletionHandler
        
        // TODO: Finish the player tap and increment time elapsed in handler
        let playerTap = RawDataTap2.init(player, handler: {floats in
            Log(floats)
        })
    }
    
    func newLocalMessage(file: AVAudioFile) throws {
        if player.isPlaying {
            messageQueue.append(file)
        } else {
            startPlaybackAudioEngine()
            try player.load(file: file, buffered: true)
            if player.isBuffered {
                playbackState = PlaybackState.isReady(player.file)
            }
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
    
    // TODO:
    /*
    private func changeNowPlayingItem() {
        IOSNowPlayableBehavior().handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata(assetURL: <#T##URL#>, mediaType: <#T##MPNowPlayingInfoMediaType#>, isLiveStream: <#T##Bool#>, title: <#T##String#>, artist: <#T##String?#>, artwork: <#T##MPMediaItemArtwork?#>, albumArtist: <#T##String?#>, albumTitle: <#T##String?#>))
    }
    */
}
