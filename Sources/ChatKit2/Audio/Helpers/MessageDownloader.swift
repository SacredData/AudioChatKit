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
