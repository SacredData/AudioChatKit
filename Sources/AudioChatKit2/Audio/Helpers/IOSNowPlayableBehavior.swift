/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
`IOSNowPlayableBehavior` implements the `NowPlayable` protocol for the iOS platform.
*/

import Foundation
import MediaPlayer

class IOSNowPlayableBehavior: NowPlayable {
    
    var defaultAllowsExternalPlayback: Bool { return true }
    
    var defaultRegisteredCommands: [NowPlayableCommand] {
        return [.togglePausePlay, // toggle record/stoprecord
                .play, // allow audio playack
                .pause, // stop audio playback
                .nextTrack, // skip audio message playing in hands-free mode
                .previousTrack, // start current audio message over again in hands-free mode
                .changePlaybackPosition,
                .changePlaybackRate,
                .enableLanguageOption,
                .disableLanguageOption
        ]
    }
    
    var defaultDisabledCommands: [NowPlayableCommand] {
        
        // By default, no commands are disabled.
        
        return [.skipForward, // no seeking in scope for now
                .skipBackward // no seeking in scope for now
        ]
    }
    
    // The observer of audio session interruption notifications.
    
    private var interruptionObserver: NSObjectProtocol!
    
    // The handler to be invoked when an interruption begins or ends.
    
    private var interruptionHandler: (NowPlayableInterruption) -> Void = { _ in }
    
    func handleNowPlayableConfiguration(commands: [NowPlayableCommand],
                                        disabledCommands: [NowPlayableCommand],
                                        commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus,
                                        interruptionHandler: @escaping (NowPlayableInterruption) -> Void) throws {
        
        // Remember the interruption handler.
        
        self.interruptionHandler = interruptionHandler
        
        // Use the default behavior for registering commands.
        
        try configureRemoteCommands(commands, disabledCommands: disabledCommands, commandHandler: commandHandler)
    }
    
    /// Call this *right before* you begin playback.
    func handleNowPlayableSessionStart() throws {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // Observe interruptions to the audio session.
        
        interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification,
                                                                      object: audioSession,
                                                                      queue: .main) { notification in
            // [unowned self] notification in
            self.handleAudioSessionInterruption(notification: notification)
        }
        
        // configure AVAudioSession for playback by defualt
        try audioSession.setCategory(.playback, mode: .spokenAudio, policy: .longFormAudio)
        
         // Make the audio session active.
        
         try audioSession.setActive(true)
    }
    
    /// Call this *directly after* the app stops playing audio
    func handleNowPlayableSessionEnd() {
        
        // Stop observing interruptions to the audio session.
        
        interruptionObserver = nil
        
        // Make the audio session inactive.
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session, error: \(error)")
        }
    }
    
    /// Run this *directly after* the player source changes, i.e., right after new message begins playing
    func handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata) {
        
        // Use the default behavior for setting player item metadata.
        
        setNowPlayingMetadata(metadata)
    }
    
    /// Periodically run this during playback to update NowPlayingInfo about current playback status/state/progress
    func handleNowPlayablePlaybackChange(playing: Bool, metadata: NowPlayableDynamicMetadata) {
        
        // Use the default behavior for setting playback information.
        
        setNowPlayingPlaybackInfo(metadata)
    }
    
    // Helper method to handle an audio session interruption notification.
    private func handleAudioSessionInterruption(notification: Notification) {
        
        // Retrieve the interruption type from the notification.
        
        guard let userInfo = notification.userInfo,
            let interruptionTypeUInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeUInt) else { return }
        
        // Begin or end an interruption.
        
        switch interruptionType {
            
        case .began:
            
            // When an interruption begins, just invoke the handler.
            
            interruptionHandler(.began)
            
        case .ended:
            
            // When an interruption ends, determine whether playback should resume
            // automatically, and reactivate the audio session if necessary.
            
            do {
                
                try AVAudioSession.sharedInstance().setActive(true)
                
                var shouldResume = false
                
                if let optionsUInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                    AVAudioSession.InterruptionOptions(rawValue: optionsUInt).contains(.shouldResume) {
                    shouldResume = true
                }
                
                interruptionHandler(.ended(shouldResume))
            }
            
            // When the audio session cannot be resumed after an interruption,
            // invoke the handler with error information.
                
            catch {
                interruptionHandler(.failed(error))
            }
            
        @unknown default:
            break
        }
    }
}
