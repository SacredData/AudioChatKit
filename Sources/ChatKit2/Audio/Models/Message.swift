//
//  Message.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import AVFoundation

final class Message: ObservableObject {
    let audioFile: AVAudioFile
    let author: String
    let date: Date
    let duration: TimeInterval
    let teamName: String
    let uploadId: String
    
    var transcript: Transcript?
    var translations: [Translation] = []
    init(audioFile: AVAudioFile, author: String="", date: String="", teamName: String="") {
        self.audioFile = audioFile
        self.author = author
        self.date = ISO8601DateFormatter().date(from: date) ?? Date()
        self.duration = audioFile.duration
        self.teamName = teamName
        self.uploadId = audioFile.url.lastPathComponent.replacingOccurrences(of: ".caf", with: "")
    }
    func attachTranscript(transcript: Transcript) {
        self.transcript = transcript
    }
    func attachTranslations(translations: [Translation]) {
        self.translations.append(contentsOf: translations)
    }
}
