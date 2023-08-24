//
//  AudioCalculations.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import Accelerate
import AVFoundation

/// Class for calculating static and real-time audio metrics for the UI
class AudioCalculations: ObservableObject {
    let stride = vDSP_Stride(1)
    var dbArray: [CGFloat] = [10.0, 10.0, 10.0]
    var dbFloatsUI: [Float] = [10.0, 10.0, 10.0]
    var recDbRMS: Float = .nan

    /// Every audio callback containing floats, call this function to re-calculate
    /// audio dB RMS and modify the CGFloats used in the UI to provide
    /// audio input visualizations.
    func updateDbArray(_ audioData: [Float]) {
        let n = vDSP_Length(audioData.count)
        vDSP_rmsqv(audioData,
                   stride,
                   &recDbRMS,
                   n)
       
        let appendVal = recDbRMS * 1000
       
        dbFloatsUI.removeFirst()
        dbFloatsUI.append(appendVal > 40.0 ? 40.0 : appendVal)
        dbFloatsUI = vDSP.threshold(dbFloatsUI,
                                    to: 10.0,
                                    with: .clampToThreshold)

        DispatchQueue.main.async {
            self.dbArray.removeFirst()
            self.dbArray.append(CGFloat(self.dbFloatsUI[2]))
        }
    }
}