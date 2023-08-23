//
//  Playlist.swift
//  storyboard-v2
//
//  Created by Andrew Grathwohl on 8/9/23.
//

import AVFoundation
import Combine
import MediaPlayer


/// The FeedPlaylist is a way to maintain a playlist of feed items for hands-free
/// playback functionality. To instantiate a class instance, prepare an array of
/// AVAudioFile instances reading from the local file system. From there we
/// auto-generate the segments for the MultiSegmentPlayer and schedule
/// timing to ensure the audio session remains active.
final class FeedPlaylist: ObservableObject {
    var accountId: String
    var audioFiles: [AVAudioFile]
    var feedId: String
    var teamName: String
    var referenceTimestamp: TimeInterval
    init(id: String, teamName: String, accountId: String, audioFiles: [AVAudioFile], referenceTimestamp: TimeInterval?) {
        self.feedId = id
        self.teamName = teamName
        self.accountId = accountId
        self.audioFiles = audioFiles
        self.referenceTimestamp = referenceTimestamp ?? 0.0
    }
    var totalDuration: TimeInterval {
        audioFiles
            .map( {$0.duration } )
            .reduce(0, +)
    }
    var totalPlaybackDuration: TimeInterval {
        totalDuration - referenceTimestamp
    }
    var filesCount: Int {
        audioFiles.count
    }
    var uploadIds: [String] {
        audioFiles.map({$0.url.lastPathComponent.replacingOccurrences(of: ".caf", with: "")})
    }
    var playbackStartTimes: [TimeInterval] {
        var lengthCounter: TimeInterval = 0.0
        var itemCounter: Int = 0
        var startTimes: [TimeInterval] = []
        audioFiles.forEach({file in
            startTimes.append(lengthCounter)
            lengthCounter = lengthCounter + file.duration
            if itemCounter == 0 {
                lengthCounter = lengthCounter - referenceTimestamp
            }
            itemCounter = itemCounter + 1
        })
        return startTimes
    }
    var totalElapsedPlaybackTime: TimeInterval = 0.0
    var currentlyPlayingSegment: segment? {
        if (totalElapsedPlaybackTime > 0.0) {
            let segIndex = segments.last(where: {$0.playbackStartTime <= totalElapsedPlaybackTime})
            return segIndex
        } else {
//            return segments[0]
          return nil
        }
    }
    var currentSegmentTimestamp: TimeInterval {
        let beginning = currentlyPlayingSegment?.playbackStartTime
        let segmentTimestamp = totalElapsedPlaybackTime - beginning!
        return segmentTimestamp
    }
    var currentSegmentProgress: TimeInterval {
        return currentSegmentTimestamp / currentlyPlayingSegment!.fileEndTime
    }
    var started: Bool {
        if totalDuration > 0.0, totalElapsedPlaybackTime > 0.0, filesCount >= 1 {
            return true
        } else {
            return false
        }
    }
    var inProgress: Bool {
        if !completed, started, totalDuration > 0.0 {
            return totalElapsedPlaybackTime > 0.0
        } else {
            return false
        }
    }
    var completed: Bool {
        totalElapsedPlaybackTime >= totalDuration
    }
    var bookmark: Bookmark?
    var segments: [segment] {
        var segCounter = 0
        var segs: [segment] = []
        audioFiles.forEach({file in
            let segmentIndex = segCounter
            let trackNumber = segmentIndex + 1 // Apple wants this to be 1-indexed
            let totalTracks = filesCount
            var mediaItem = [String: Any]()
            var nowPlayingInfo = [String: Any]()

            mediaItem[MPMediaItemPropertyAssetURL] = file.url.absoluteString
            mediaItem[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio
            mediaItem[MPMediaItemPropertyPlaybackDuration] = file.duration
            //mediaItem[MPMediaItemPropertyArtist] = audioCreator
            mediaItem[MPMediaItemPropertyAlbumTitle] = teamName
            mediaItem[MPMediaItemPropertyDateAdded] = NSDate.now
            mediaItem[MPMediaItemPropertyAlbumTrackNumber] = trackNumber
            mediaItem[MPMediaItemPropertyAlbumTrackCount] = totalTracks

            if let image = UIImage(named: "SBAppIcon1024") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            mediaItem[MPMediaItemPropertyArtwork] = artwork
            }
            
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = totalTracks
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = segmentIndex
            nowPlayingInfo[MPNowPlayingInfoCollectionIdentifier] = feedId
            nowPlayingInfo[MPNowPlayingInfoPropertyExternalContentIdentifier] = uploadIds[segmentIndex]
            nowPlayingInfo[MPNowPlayingInfoPropertyExternalUserProfileIdentifier] = accountId
            nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = NSNumber(0.0)

            let seg = segment(audioFile: audioFiles[segmentIndex],
                              playbackStartTime: playbackStartTimes[segmentIndex],
                              fileStartTime: segmentIndex == 0 ? referenceTimestamp : 0.0,
                              fileEndTime: audioFiles[segmentIndex].duration,
                              completionHandler: {
                                Logger.log("Completed playback of Audio Message #\(trackNumber): \(self.uploadIds[segmentIndex])")
                              },
                              teamName: teamName,
                              accountId: accountId,
                              feedId: feedId,
                              feedItemId: uploadIds[segmentIndex],
                              mediaItem: mediaItem,
                              nowPlayingInfo: nowPlayingInfo)
            segs.append(seg)
            segCounter = segCounter + 1
        })
        return segs
    }

    func updateTimestamp(timeStamp: TimeInterval) {
        totalElapsedPlaybackTime = timeStamp
    }

    func setBookmark(segment: segment, timeStamp: TimeInterval) {
        let segmentDuration = segment.audioFile.duration
        let segmentStartTime = segment.playbackStartTime
        let relativeTime = timeStamp - segmentStartTime
        let progress = relativeTime / segmentDuration
        let newBookmark = Bookmark(segment: segment, absoluteTimestamp: timeStamp, relativeTimestamp: relativeTime, segmentProgress: Float(progress))

        bookmark = newBookmark
    }

    struct Bookmark {
        var segment: segment
        var absoluteTimestamp: TimeInterval
        var relativeTimestamp: TimeInterval // absolute - playbackStartTime
        var segmentProgress: Float // relativeTimestamp / segment.audioFile.duration
    }
}

public struct segment: StreamableAudioSegment {
  public var audioFile: AVAudioFile
  public var playbackStartTime: TimeInterval
  public var fileStartTime: TimeInterval
  public var fileEndTime: TimeInterval
  public var completionHandler: AVAudioNodeCompletionHandler?
  public var audioCreator: String?
  public var teamName: String?
  public var accountId: String?
  public var feedId: String?
  public var feedItemId: String?
  public var transcript: String?
  public var mediaItem: [String: Any]?
  public var nowPlayingInfo: [String: Any]?
}
