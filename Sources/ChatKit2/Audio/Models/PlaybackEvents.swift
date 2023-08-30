//
//  PlaybackEvents.swift
//  
//
//  Created by Andrew Grathwohl on 8/30/23.
//  Enum for reporting user playback events
//

import Foundation

enum PlaybackEvents {
    case play(Date?, Message?)
    case stop(Date?, Message?, TimeInterval?)
    case pause(Date?, Message?, TimeInterval?)
    case resume(Date?, Message?, TimeInterval?)
    case seek(Date?, Message?, [TimeInterval]?)
    case completion(Date?, Message?)
    case interruption
    case error
}
