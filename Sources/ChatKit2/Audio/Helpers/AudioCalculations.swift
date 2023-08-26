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
    let stride = vDSP_Stride(1)
    @Published var dbArray: [CGFloat] = [10.0, 10.0, 10.0]
    var dbFloatsUI: [Float] = [10.0, 10.0, 10.0]
    var recDbRMS: Float = .nan

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
    
    public func getPeak(audioBuffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer.Peak {
        return audioBuffer.peak()!
    }
}
