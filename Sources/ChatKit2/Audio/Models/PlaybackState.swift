import AVFoundation

enum PlaybackState {
    case isWaiting
    case isScheduling(AVAudioFile?)
    case isBuffering(AVAudioFile?)
    case isPaused(AVAudioFile?)
    case isStopped(AVAudioFile?)
    case isPlaying(AVAudioFile?)
    case isReady(AVAudioFile?)
    case isInterrupted(AVAudioFile?)
}
