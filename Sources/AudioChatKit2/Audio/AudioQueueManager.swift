//
//  HandsFreeManager.swift
//  storyboard-v2
//
//  Created by Andrew Grathwohl on 8/21/23.
//

import AVFoundation

class AudioQueueManager: ObservableObject {
    static var shared: AudioQueueManager = AudioQueueManager()
    var playbackState: PlaybackState = .isInitializing
    
    // The pending audio messages to play when player is freed up
    var messageQueue: [AVAudioFile] = []
    
    private init() {
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
    }
}
