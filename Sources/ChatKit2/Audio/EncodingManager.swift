//
//  EncodingManager.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import AudioKit
import AVFoundation

class EncodingManager: ObservableObject {
    let bitrate: Int = FormatConverterSettings.bitrate
    let sampleRate: Int = FormatConverterSettings.sampleRate
    let channelCount: Int = FormatConverterSettings.channels
    let audioCodec: String = FormatConverterSettings.format

    let outputDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    func encodeToM4A(at inputURL: URL, for accountId: String="", in teamId: String="") -> URL {
        let outputURL = outputDirectory.appendingPathComponent("\(inputURL.lastPathComponent).converted.m4a")
        var options = FormatConverter.Options()
        options.format = AudioFileFormat(rawValue:audioCodec)
        options.sampleRate = Double(sampleRate)
        options.channels = UInt32(channelCount)
        options.bitRate = UInt32(bitrate)
        
        let converter = FormatConverter(inputURL: inputURL, outputURL: outputURL, options: options)
        
        converter.start { error in
            if let error {
                fatalError("\(error)")
            }
        }
        
        return outputURL
    }
}
