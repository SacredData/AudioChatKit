import AVFoundation

enum AudioFormats {
    static let record = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                      sampleRate: 48000,
                                      channels: 1,
                                      interleaved: true)
    static let global = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                      sampleRate: 48000,
                                      channels: 2,
                                      interleaved: true)
}
