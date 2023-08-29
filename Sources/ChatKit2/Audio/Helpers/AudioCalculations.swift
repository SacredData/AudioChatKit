//
//  AudioCalculations.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import Accelerate
import AudioKit
import AVFoundation

/// Class for calculating static and real-time audio metrics for the UI
public class AudioCalculations: ObservableObject {
    static var shared: AudioCalculations = AudioCalculations()
    let stride = vDSP_Stride(1)
    @Published var dbArray: [CGFloat] = [10.0, 10.0, 10.0]
    var dbFloatsUI: [Float] = [10.0, 10.0, 10.0]
    var recDbRMS: Float = .nan

    let outputFormat: AVAudioFormat = AudioFormats.global!

    /// Every audio callback containing floats, call this function to re-calculate
    /// audio dB RMS and modify the CGFloats used in the UI to provide
    /// audio input visualizations.
    public func updateDbArray(_ audioData: [Float]) {
        DispatchQueue.global(qos: .userInteractive).async {
            let n = vDSP_Length(audioData.count)
            vDSP_rmsqv(audioData,
                       self.stride,
                       &self.recDbRMS,
                       n)
           
            let appendVal = self.recDbRMS * 1000
           
            self.dbFloatsUI.removeFirst()
            self.dbFloatsUI.append(appendVal > 40.0 ? 40.0 : appendVal)
            self.dbFloatsUI = vDSP.threshold(self.dbFloatsUI,
                                        to: 10.0,
                                        with: .clampToThreshold)

            DispatchQueue.main.async {
                self.dbArray.removeFirst()
                self.dbArray.append(CGFloat(self.dbFloatsUI[2]))
            }
        }
    }
    
    /// For the provied audio buffer, returns the loudest moment in the file
    public func getPeak(audioBuffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer.Peak {
        return audioBuffer.peak()!
    }

    // TODO: Finish this up and make it do something useful
    public func bufferFromFloats(floats: [Float]) {
        var f: [Float] = []
        f.append(contentsOf: floats)

        f.withUnsafeMutableBufferPointer { bytes in
            let ab = AudioBuffer(
                mNumberChannels: 2,
                mDataByteSize: UInt32(bytes.count * MemoryLayout<Float>.size),
                mData: bytes.baseAddress)
            var bl = AudioBufferList(mNumberBuffers: 1, mBuffers: ab)
            let ob = AVAudioPCMBuffer(pcmFormat: self.outputFormat, bufferListNoCopy: &bl)!
            Log(ob.frameLength)
            Log(ob.floatChannelData)
            let pk = self.getPeak(audioBuffer: ob)
            Log(pk)
        }
    }
}
