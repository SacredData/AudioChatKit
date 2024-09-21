//
//  PlaybackEvents.swift
//  
//
//  Created by Andrew Grathwohl on 8/30/23.
//  Enum for reporting user playback events
//

import Foundation

enum PlaybackEvents {
    case play(Date?)
    case stop(Date?, TimeInterval?)
    case pause(Date?, TimeInterval?)
    case resume(Date?, TimeInterval?)
    case seek(Date?, [TimeInterval]?)
    case completion(Date?)
    case interruption
    case error
}
