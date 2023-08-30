import AVFoundation

enum PlaybackState {
    case isInitializing
    case isWaiting
    case isScheduling(AVAudioFile?)
    case isBuffering(AVAudioFile?)
    case isPaused(AVAudioFile?)
    case isStopped
    case isPlaying(AVAudioFile?)
    case isReady(AVAudioFile?)
    case isInterrupted(AVAudioFile?)
}
