//
//  MessageDownloader.swift
//  
//
//  Created by Andrew Grathwohl on 8/30/23.
//

import AudioKit
import AVFoundation
import Foundation

public class MessageDownloader: ObservableObject {
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
        guard let tracks = msg.tracks else { return }
        Log(tracks)
        let fmt = try await assetTrackCharacteristics(track: tracks.first!)
        Log(fmt)
    }
    
    // TODO: WIP
    public func download(url: URL) async throws {
        // Create AVURLAsset from the URL first and get its properties
        let assetURL = AVAsset(url: url)
        let assetCharacteristics = try await assetCharacteristics(asset: assetURL as! AVURLAsset)
        Log(assetCharacteristics)

        // Get the audio track from the container and get its codec properties
        let assetTrack = try await assetURL.loadTracks(withMediaType: .audio)
        let trackCharacteristics = try await assetTrackCharacteristics(track: assetTrack.first!)
        Log(trackCharacteristics)
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
