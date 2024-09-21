//
//  EncodingManager.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import AudioKit
import AVFoundation
import Opus
import SwiftOGG

public class EncodingManager: ObservableObject {
    public let audioCalcs: AudioCalculations = .shared
    let bitrate: Int = FormatConverterSettings.bitrate
    let sampleRate: Int = FormatConverterSettings.sampleRate
    let channelCount: Int = FormatConverterSettings.channels
    let audioCodec: String = FormatConverterSettings.format

    var opusEncoder: Opus.Encoder?
    let outputDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var latestM4a: URL?
    var latestOpus: URL?

    /// Produces a mono M4A-contained AAC audio file from a mono Float32 48kHz PCM source
    func encodeToM4A(at inputURL: URL) -> URL {
        let outputURL = outputDirectory.appendingPathComponent("\(inputURL.lastPathComponent).converted.m4a")
        var options = FormatConverter.Options()
        options.format = AudioFileFormat(rawValue:audioCodec)
        options.sampleRate = Double(sampleRate)
        options.channels = UInt32(channelCount)
        options.bitRate = UInt32(bitrate)
        options.eraseFile = true
        
        let converter = FormatConverter(inputURL: inputURL, outputURL: outputURL, options: options)
        converter.start { error in
            if let error {
                fatalError("\(error)")
            }
        }

        // Save this in case opus encoding fails for some reason so we can recover
        latestM4a = outputURL

        return outputURL
    }

    /// Produces a mono OGG-contained Opus audio file from a mono Float32 48kHz PCM source
    func encodeToOpus(at inputURL: URL) throws -> URL {
        let outputURL = outputDirectory.appendingPathComponent("\(inputURL.lastPathComponent).converted.opus")
        let srcURL = encodeToM4A(at: inputURL)
        try OGGConverter.convertM4aFileToOpusOGG(src: srcURL, dest: outputURL)
        latestOpus = outputURL
        return outputURL
    }
    
    public func floatsToOpus(floats: [Float]) throws {
        if opusEncoder == nil {
            do {
                try instantiateOpusEncoder()
            } catch {
                Log(error)
                return
            }
        }
        var data = Data(count: 0)
        audioCalcs.bufferFromFloatsStereo(floats: floats)
        guard let buf = audioCalcs.pcmOutputBufferStereo else { return }
        let encCount = try opusEncoder?.encode(buf, to: &data)
        Log(encCount, data)
        try opusEncoder?.reset()
    }

    /* TODO: Figure out what is going wrong with the floats operation
    /// Produces an opus packet from a series of PCM float values
    /// Assumes a 48kHz sampling rate, mono channel layout, and 32bit depth
    func encodeFloatsToOpusPacket(floats: [Float]) throws {
        // TODO: instantiate class instance of Opus.Encoder
        try instantiateOpusEncoder()
        var data = Data(count: 0)
        // TODO: audiobuffer from [Float]
        try floats.withUnsafeMutableBufferPointer { bytes in
            let audioBuffer = AudioBuffer(mNumberChannels: 1, mDataByteSize: UInt32(bytes.count * MemoryLayout<Float>.size), mData: bytes.baseAddress)
            var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: audioBuffer)
            let outputAudioBuffer = AVAudioPCMBuffer(pcmFormat: AudioFormats.record?.commonFormat, bufferListNoCopy: &bufferList)!
     
            _ = try opusEncoder.encode(outputAudioBuffer, to: &data)
        }
        // TODO: audiobuffer -> opus packet
    }
     */

    private func instantiateOpusEncoder() throws {
        opusEncoder = try Opus.Encoder(format: AudioFormats.record!)
    }
}
