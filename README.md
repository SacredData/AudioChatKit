# ChatKit2
> Storyboard's iOS audio toolkit

## About
ChatKit2 is a Swift Package meant to establish and solidify important audio
standards that our app must follow to be [`NowPlayable`][np]. In so-doing, we setup
the iOS app developers for success by removing the need to maintain a thorough
understanding of the Apple ecosystem's intense audio implementation requirements.

The code in this package is meant to be relatively static and unchanging. If we
need to make any modifications to this package, it is because we have expanded
our application's business requirements such that new standards must now be
achieved, or because Apple's own internal standards/requirements have been
changed.

### VIPER Architecture
ChatKit2 pursues the only logic iOS app architecture suitable for a real-time,
offline-first audio messaging use case: [**VIPER**](https://www.kodeco.com/8440907-getting-started-with-the-viper-architecture-pattern).

Successful deployment of ChatKit2 will depend upon the implementer's discipline
to retain this app architecture and to consider it a primary design goal.

### Development
All changes to this library, once implemented into Chat by Storyboard for iOS,
will be required to go through code review via GitHub pull request.

## Features

- [x] Automated `AVAudioEngine` and `AVAudioSession` configuration management
- [x] Data models for Storyboard's defined product entities
- [x] Audio playback with full `NowPlayable` and `RemoteCommandCenter` support on iOS
- [x] Audio recording node that works in the background and transcodes on-the-fly
- [x] Playback and recording time tracking managed headlessly
- [x] Audio output processing that enhances speech clarity
- [ ] Audio input processing that reduces file size and improves transcription quality (in progress)
- [x] Properly-threaded audio routines that never exceed 15% CPU
- [x] Audio downloading and asset caching modules that enable offline playback
- [x] Support for AirPlay and AirPlay 2

## Usage Guide

### Types Implemented
#### Dates & Times
| Use Case | Type |
|----------------------------------|------|
|Audio message duration            | [`TimeInterval`](https://developer.apple.com/documentation/foundation/timeinterval)|
|Message creation date      | [`ISO8601DateFormatter`](https://developer.apple.com/documentation/foundation/iso8601dateformatter)|
|Playback progress tracking  | [`AVAudioTime`](https://developer.apple.com/documentation/avfaudio/avaudiotime)|
#### Audio Nodes
| Use Case | Type |
|------------------|------|
|Audio engine  | [`AudioKit.AudioEngine`](https://www.audiokit.io/AudioKit/documentation/audiokit/audioengine)|
|Audio player | [`AudioKit.AudioPlayer`](https://www.audiokit.io/AudioKit/documentation/audiokit/audioplayer)|
|Audio recorder | [`AudioKit.NodeRecorder`](https://www.audiokit.io/AudioKit/documentation/audiokit/noderecorder)|
|Mixer | [`AudioKit.Mixer`](https://www.audiokit.io/AudioKit/documentation/audiokit/mixer)|
|Playback tap | [`AudioKit.RawDataTap`](https://www.audiokit.io/AudioKit/documentation/audiokit/audioplayer)|
|Record tap| [`AudioKit.AmpltidueTap`](https://www.audiokit.io/AudioKit/documentation/audiokit/amplitudetap)|

### Data Models Implemented
#### Structs
| Model          | Source File |
|----------------|--------------|
|`Message`       | [`Models/Message.swift`](https://github.com/Storyboard-fm/ChatKit/blob/main/Sources/ChatKit2/Audio/Models/Message.swift)|
|`Transcript`    | [`Models/Transcript.swift`](https://github.com/Storyboard-fm/ChatKit/blob/main/Sources/ChatKit2/Audio/Models/Transcript.swift)|
#### Enums
| Enum           | Source File |
|----------------|-------------|
|`AudioFormats` | [`Models/AudioFormats.swift`](https://github.com/Storyboard-fm/ChatKit/blob/main/Sources/ChatKit2/Audio/Models/AudioFormats.swift)|
|`AudioKitSettings` | [`Models/AudioKitSettings.swift`](https://github.com/Storyboard-fm/ChatKit/blob/main/Sources/ChatKit2/Audio/Models/AudioKitSettings.swift)|
|`PlaybackEvents`| [`Models/PlaybackEvents.swift`](https://github.com/Storyboard-fm/ChatKit/blob/main/Sources/ChatKit2/Audio/Models/PlaybackEvents.swift)|
|`PlaybackState` | [`Models/PlaybackState.swift`](https://github.com/Storyboard-fm/ChatKit/blob/main/Sources/ChatKit2/Audio/Models/PlaybackState.swift)|

### Setup
> Always do these things first!

**Immediately after app launch** create an instance of `AudioConfigHelper` inside the app's `init()` function.

```swift
init() {
    let configHelper = AudioConfigHelper()
    if configHelper.sessionPreferencesAreValid {
        Log("Session is configured correctly for longForm spoken audio playback")
    } else {
        Log("Uh oh! Something is wrong with our audio configuration.")
    }
}
```

We always start the app in its default session configuration of:

- Category: [`.playback`](https://developer.apple.com/documentation/avfaudio/avaudiosession/category/1616509-playback)
- Mode: [`.spokenAudio`](https://developer.apple.com/documentation/avfaudio/avaudiosession/mode/1616510-spokenaudio)
- Policy: [`.longFormAudio`](https://developer.apple.com/documentation/avfaudio/avaudiosession/routesharingpolicy/longformaudio)

### Launch the `AudioConductor`

Once we have done the necessary setup of our audio configuration, we can init
the `AudioConductor` which is the simple class we use to manage AudioKit's
audio objects and resources.

```swift

struct AViewOfSomeKind: View {
    @StateObject var conductor = AudioConductor()

    //setup UI view stuff
}
```

By doing this you now have access to all audio features provided by `AudioKit`.

#### Starting and Stopping `AudioConductor`
***DON'T DO IT***

We implement automated start/stop functionality inside the classes so you don't
have to manage these concerns in the first place.

### Using the `PlaybackManager`
The best way to access and utilize our playback tools is via `AudioConductor.playerMan`.

You must utilize this manager in order to get access to the class-managed timing
metadata needed for UI relating to playback progress.

***NEVER use a `Timer` or `Date` to do anything related to playback time
tracking!!*** Instead, read on to learn how to access the class-managed values.

#### Time Metadata for UI
##### Formatted Time String
> For publishing real-time seconds elapsed to UI

We publish time elapsed in seconds at [`PlaybackManager.currentTimeString`](https://github.com/Storyboard-fm/ChatKit/blob/341a4cef5cd8133b9d29391c32722c68f42e1566/Sources/ChatKit2/Audio/PlaybackManager.swift#L33).

##### Progress Float
> For use in SwiftUI as a `CGFloat`

We also publish the float used to increment playback progress at [`PlaybackManager.currentProgress`](https://github.com/Storyboard-fm/ChatKit/blob/341a4cef5cd8133b9d29391c32722c68f42e1566/Sources/ChatKit2/Audio/PlaybackManager.swift#L27).

## Examples

### Create and play a new `Message`

```swift
let fileURL: URL = // get local file URL somehow...
let msg = Message(audioFile: AVAudioFile(forReading: fileURL))
try conductor.playerMan.newLocalMessage(msg: msg)
```

Note: if the player is currently playing something, `playerMan` will add the new
`Message` to its queue and execute playback in order received.

### Introspect the currently-loaded `Message`

```swift
// picking up from previous message playback example above
try conductor.playerMan.newLocalMessage(msg: msg)
Log(conductor.playerMan.nowPlayableMessage) // this is the "now playing" audio message
// Some example properties of the `Message` struct:
Log(conductor.playerMan.nowPlayableMessage.audioFile.url)
Log(conductor.playerMan.nowPlayableMessage.audioFile.duration)
Log(conductor.playerMan.nowPlayableMessage.author)
Log(conductor.playerMan.nowPlayableMessage.staticMetadata)
```


[np]: https://developer.apple.com/documentation/mediaplayer/becoming_a_now_playable_app
