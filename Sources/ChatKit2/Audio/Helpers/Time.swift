//
//  Time.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import AVFoundation

/// Various helper methods for handling time best-practices
final class TimeHelper: ObservableObject {
    
    /// Returns a well-formatted MM:ss string from a given `TimeInterval`
    func formatDuration(duration: TimeInterval) -> String {
        let time = TimeInterval(duration)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
       
        let retTime = formatter.string(from: time)
        return retTime!
    }
    
    func audioSampleTime(audioFile: AVAudioFile) -> AVAudioTime {
        let framePosition = audioFile.framePosition
        let sampleRate = audioFile.fileFormat.sampleRate
        return AVAudioTime.init(sampleTime: framePosition, atRate: sampleRate)
    }
}

