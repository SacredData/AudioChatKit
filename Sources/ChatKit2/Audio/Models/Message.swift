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
    let feedId: String
    let teamName: String
    let uploadId: String
    
    var transcript: Transcript? {
        didSet {
            self.spokenLanguage = transcript?.languageOption.languageTag
        }
    }
    var translations: [Translation] = []
    var spokenLanguage: String?
    var usersListened: [String] = []
    init(audioFile: AVAudioFile, author: String="", date: String="", feedId: String="", teamName: String="") {
        self.audioFile = audioFile
        self.author = author
        self.date = ISO8601DateFormatter().date(from: date) ?? Date()
        self.duration = audioFile.duration
        self.feedId = feedId
        self.teamName = teamName
        self.uploadId = audioFile.url.lastPathComponent.replacingOccurrences(of: ".caf", with: "")
    }
    /// Attach the `Transcript` belonging to this message
    /// This also sets the message's spoken language property
    func attachTranscript(transcript: Transcript) {
        self.transcript = transcript
    }
    /// Attach a `Translation` of this message's `Transcript`
    func attachTranslations(translations: [Translation]) {
        self.translations.append(contentsOf: translations)
    }
    /// Set this when we know that a new user has listened to the message
    func setUsersListened(accountIds: [String]) {
        usersListened.append(contentsOf: accountIds)
    }
}
