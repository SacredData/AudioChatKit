//
//  WhisperHelper.swift
//  
//
//  Created by Andrew Grathwohl on 9/3/23.
//

import AudioKit
import Foundation
import SwiftWhisper

public class Whisperer {
    let fileDir: URL = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask).first!
    let modelPath: URL
    
    public init() {
        modelPath = fileDir.appendingPathComponent("ggml-tiny.bin")
        let whisper = Whisper(fromFileURL: modelPath)
        Log(whisper)
    }
}

protocol WhisperDelegate {
  // Progress updates as a percentage from 0-1
  func whisper(_ aWhisper: Whisper, didUpdateProgress progress: Double)

  // Any time a new segments of text have been transcribed
  func whisper(_ aWhisper: Whisper, didProcessNewSegments segments: [Segment], atIndex index: Int)
  
  // Finished transcribing, includes all transcribed segments of text
  func whisper(_ aWhisper: Whisper, didCompleteWithSegments segments: [Segment])

  // Error with transcription
  func whisper(_ aWhisper: Whisper, didErrorWith error: Error)
}
