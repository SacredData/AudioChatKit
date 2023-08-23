//
//  HandsFreeManager.swift
//  storyboard-v2
//
//  Created by Andrew Grathwohl on 8/21/23.
//

import AudioKit
import AVFoundation

class PlaybackManager: ObservableObject, ProcessesPlayerInput, HasAudioEngine {
    static var shared: PlaybackManager = PlaybackManager()

    var engine: AudioKit.AudioEngine
    var mixer: AudioKit.Mixer
    var player: AudioKit.AudioPlayer
    var session: AVAudioSession
    
    var playbackState: HandsFreeState.PlaybackState {
        didSet {
            // TODO: Handle changes in playback state
            switch playbackState {
            case .isReady:
                playMessage()
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
        engine = AudioEngine()
        session = AudioKit.Settings.session

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
    }

    func newLocalMessage(file: AVAudioFile) throws {
        if player.isPlaying {
            messageQueue.append(file)
        } else {
            startPlaybackAudioEngine()
            try player.load(file: file, buffered: true)
            if player.isBuffered {
                playbackState = HandsFreeState.PlaybackState.isReady(player.file)
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
                playbackState = HandsFreeState.PlaybackState.isPlaying(player.file)
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
        } catch {
            return
        }
    }
    
    private func configurePlaybackSession() throws {
        try IOSNowPlayableBehavior().handleNowPlayableSessionStart()
        logCurrentSessionInfo()
    }
}
