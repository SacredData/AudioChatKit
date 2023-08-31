//
//  MessageDownloader.swift
//  
//
//  Created by Andrew Grathwohl on 8/30/23.
//

import AudioKit
import AVFoundation
import Foundation

public class MessageDownloader {
    public static var shared: MessageDownloader = MessageDownloader()
    let storageManager: AVAssetDownloadStorageManager = AVAssetDownloadStorageManager.shared()
    let evictionPriority: AVAssetDownloadedAssetEvictionPriority = .important
    
    public init() {
        print("Message downloaded init'd")
    }
    
    public func newRemoteMessage(url: URL) async throws {
        let msg = Message(url: url, author: nil)
        guard let avAsset = msg.avAsset else { return }
        Log(avAsset)
        let chars = try await assetCharacteristics(asset: avAsset)
        try await msg.getAssetTracks()
        guard let track = msg.tracks!.first else { return }
        Log(track)
        let fmt = try await assetTrackCharacteristics(track: track)
        Log(fmt)
    }
    
    // TODO: WIP
    public func download(url: URL) async throws {
        lazy var urlSession: URLSession = {
            let config = URLSessionConfiguration.default
            config.isDiscretionary = true
            config.sessionSendsLaunchEvents = true
            config.waitsForConnectivity = true
            config.shouldUseExtendedBackgroundIdleMode = true
            return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        }()
        // Create AVURLAsset from the URL first and get its properties
        let assetURL = AVAsset(url: url)
        let assetCharacteristics = try await assetCharacteristics(asset: assetURL as! AVURLAsset)
        Log(assetCharacteristics)

        // Get the audio track from the container and get its codec properties
        let assetTrack = try await assetURL.loadTracks(withMediaType: .audio)
        let trackCharacteristics = try await assetTrackCharacteristics(track: assetTrack.first!)
        Log(trackCharacteristics)
        
        let downloadTask = urlSession.downloadTask(with: url, completionHandler: {_,_,_ in
            Log("WE FINISHED DOWNLOADING")
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
