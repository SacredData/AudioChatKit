//
//  Message.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

/*
 When a new message comes in, we should download the file to storage and
 create an `AVAudioFile` from the local URL of that file. This plus the
 other metadata in the init of this class should be used to instantiate
 the new AudioMessage.
 
 When we receive the original language transcript, be sure to init the
 `Transcript` and attach it to this message via `attachTranscript`.
 
 When we recveive translations of the original transcript into other languages,
 be sure to `attachTranslations` as well.
 */

import AVFoundation

public final class Message {
    let audioFile: AVAudioFile
    var author: Peer?
    let authorName: String?
    let date: Date
    let duration: TimeInterval
    let feedId: String
    let teamName: String
    let title: String
    let uploadId: String
    
    var transcript: Transcript? {
        didSet {
            self.spokenLanguage = transcript?.languageOption.languageTag
        }
    }
    var translations: [Translation] = []
    var spokenLanguage: String?
    var usersListened: [String] = []

    var staticMetadata: NowPlayableStaticMetadata
    var dynamicMetadata: NowPlayableDynamicMetadata?

    public init(audioFile: AVAudioFile, author: Peer?, date: String="", feedId: String="", teamName: String="", title: String="") {
        self.audioFile = audioFile
        self.author = author
        self.authorName = author?.name ?? ""
        self.date = ISO8601DateFormatter().date(from: date) ?? Date()
        self.duration = audioFile.duration
        self.feedId = feedId
        self.teamName = teamName
        self.title = title
        self.uploadId = audioFile.url.lastPathComponent.replacingOccurrences(of: ".caf", with: "")
        // TODO: Put artwork property into the static metadata
        self.staticMetadata = NowPlayableStaticMetadata(assetURL: self.audioFile.url, mediaType: .audio, isLiveStream: false, title: title, artist: authorName, artwork: nil, albumArtist: authorName, albumTitle: teamName)
        self.spokenLanguage = author?.locale?.identifier ?? "en-US"
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
