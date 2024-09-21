import AVFoundation

enum AudioStreamBasicDescriptions {
    static let opus = AudioStreamBasicDescription(mSampleRate: Double(AudioKitSettings.sampleRate),
                                                  mFormatID: kAudioFormatOpus,
                                                  mFormatFlags: 0,
                                                  mBytesPerPacket: 0,
                                                  mFramesPerPacket: 0,
                                                  mBytesPerFrame: 0,
                                                  mChannelsPerFrame: UInt32(AudioKitSettings.channelCount),
                                                  mBitsPerChannel: 0,
                                                  mReserved: 0
    )
}
