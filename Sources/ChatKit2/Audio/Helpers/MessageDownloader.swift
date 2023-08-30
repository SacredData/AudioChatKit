//
//  MessageDownloader.swift
//  
//
//  Created by Andrew Grathwohl on 8/30/23.
//

import AVFoundation
import Foundation

public class MessageDownloader: ObservableObject {
    let storageManager: AVAssetDownloadStorageManager = AVAssetDownloadStorageManager.shared()
    let evictionPriority: AVAssetDownloadedAssetEvictionPriority = .important
    
    public init() {
        print("Message downloaded init'd")
    }
}
