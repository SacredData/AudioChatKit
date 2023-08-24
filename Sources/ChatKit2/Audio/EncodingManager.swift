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

    /// Produces a mono M4A-contained AAC audio file from a mono Float32 48kHz PCM source
    func encodeToM4A(at inputURL: URL) -> URL {
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

    /// Produces an opus packet from a series of PCM float values
    /// Assumes a 48kHz sampling rate, mono channel layout, and 32bit depth
    func encodeFloatsToOpusPacket(floats: [Float]) {
        // TODO: audiobuffer from [Float]
        // TODO: instantiate class instance of Opus.Encoder
        // TODO: audiobuffer -> opus packet
    }
}
