//
//  MessageDownloader.swift
//  
//
//  Created by Andrew Grathwohl on 8/30/23.
//

import AudioKit
import AVFoundation
import Foundation

/// Class for managing the creation of `AVAsset` and `Message` from new remote
/// audio message URLs. Provides storage management, file introspection, and track
/// extraction for the remote audio message. By default, implements `.important`
/// eviction priority for downloaded messages.
public class MessageDownloader {
    public static var shared: MessageDownloader = MessageDownloader()
    let storageManager: AVAssetDownloadStorageManager = AVAssetDownloadStorageManager.shared()
    let evictionPriority: AVAssetDownloadedAssetEvictionPriority = .important
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.waitsForConnectivity = true
        config.shouldUseExtendedBackgroundIdleMode = true
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()

    public init() {
        print("Message downloaded init'd")
    }
    
    public func newRemoteMessage(url: URL) async throws -> [Any]{
        let msg = Message(url: url, author: nil)
        guard let avAsset = msg.avAsset else { return [msg] }
        let chars = try await assetCharacteristics(asset: avAsset)
        try await msg.getAssetTracks()
        guard let track = msg.tracks!.first else { return [msg, chars] }
        let fmt = try await assetTrackCharacteristics(track: track)
        return [msg, chars, fmt]
    }
    
    // TODO: WIP
    public func download(url: URL) async throws {
        let newMsgData = try await newRemoteMessage(url: url)
        let msg = newMsgData[0]
        let chars = newMsgData[1]
        let fmt = newMsgData[2]

        let downloadTask = urlSession.downloadTask(with: url, completionHandler: {tmpPath,_,_ in
            Log("WE FINISHED DOWNLOADING")
            Log(tmpPath!)
        })
        downloadTask.earliestBeginDate = Date()
        downloadTask.resume()
    }

    /// Retrieve important properties about a remote audio message
    private func assetCharacteristics(asset: AVAsset) async throws -> [Any] {
        let (readable, playable, duration) = try await asset.load(.isReadable,
                                        .isPlayable,
                                        .duration)
        return [readable, playable, duration]
    }
    
    /// Retrieves low-level audio properties in the audio message
    private func assetTrackCharacteristics(track: AVAssetTrack) async throws -> [Any] {
        let fmt = try await track.load(.formatDescriptions)
        return fmt
    }
}
