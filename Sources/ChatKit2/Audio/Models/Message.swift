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

import AudioKit
import AVFoundation

public final class Message {
    public var audioFile: AVAudioFile?
    public var author: Peer?
    public let authorName: String?
    public let date: Date
    public var duration: TimeInterval
    public let feedId: String
    public let teamName: String
    public let title: String
    public let uploadId: String
    
    public var transcript: Transcript? {
        didSet {
            self.spokenLanguage = transcript?.languageOption.languageTag
        }
    }
    public var translations: [Translation] = []
    public var spokenLanguage: String?
    public var usersListened: [String] = []
    
    public var mediaSelection: AVMediaSelection?
    public var avAsset: AVAsset?
    public var tracks: [AVAssetTrack]?
    
    var playbackEvents: [PlaybackEvents]?

    var staticMetadata: NowPlayableStaticMetadata
    var dynamicMetadata: NowPlayableDynamicMetadata?

    public init(audioFile: AVAudioFile, author: Peer?, date: String="", feedId: String="", teamName: String="", title: String="") {
        self.audioFile = audioFile
        self.avAsset = AVAsset(url: audioFile.url)
        self.author = author
        self.authorName = author?.name ?? ""
        self.date = ISO8601DateFormatter().date(from: date) ?? Date()
        self.duration = audioFile.duration
        self.feedId = feedId
        self.teamName = teamName
        self.title = title
        self.uploadId = audioFile.url.lastPathComponent.replacingOccurrences(of: ".caf", with: "")
        self.staticMetadata = NowPlayableStaticMetadata(assetURL: self.audioFile!.url, mediaType: .audio, isLiveStream: false, title: title, artist: authorName, artwork: nil, albumArtist: authorName, albumTitle: teamName)
        self.spokenLanguage = author?.locale?.identifier ?? "en-US"
    }
    public init(url: URL, author: Peer?, date: String="", feedId: String="", teamName: String="", title: String="") {
        self.avAsset = AVAsset(url: url)
        self.author = author
        self.authorName = author?.name ?? ""
        self.date = ISO8601DateFormatter().date(from: date) ?? Date()
        self.duration = 0
        self.feedId = feedId
        self.teamName = teamName
        self.title = title
        self.uploadId = url.lastPathComponent.replacingOccurrences(of: ".caf", with: "")
        self.staticMetadata = NowPlayableStaticMetadata(assetURL: url, mediaType: .audio, isLiveStream: false, title: title, artist: authorName, artwork: nil, albumArtist: authorName, albumTitle: teamName)
        self.spokenLanguage = author?.locale?.identifier ?? "en-US"
    }
    /// Attach the `Transcript` belonging to this message
    /// This also sets the message's spoken language property
    public func attachTranscript(transcript: Transcript) {
        self.transcript = transcript
    }
    /// Attach a `Translation` of this message's `Transcript`
    public func attachTranslations(translations: [Translation]) {
        self.translations.append(contentsOf: translations)
    }
    /// Set this when we know that a new user has listened to the message
    public func setUsersListened(accountIds: [String]) {
        usersListened.append(contentsOf: accountIds)
    }
    func getAssetTracks() async throws {
        if self.avAsset != nil {
            self.tracks = try await (self.avAsset?.loadTracks(withMediaType: .audio))!
            let trackDur = try await self.avAsset!.load(.duration)
            self.duration = TimeInterval(trackDur.seconds)
        }
    }
    func newPlaybackEvent(events: [PlaybackEvents]) {
        self.playbackEvents?.append(contentsOf: events)
    }
}
