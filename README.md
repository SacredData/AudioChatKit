# ChatKit2
> Storyboard's iOS audio toolkit

## About
ChatKit2 is a Swift Package meant to establish and solidify important audio
standards that our app must follow to be `NowPlayable`. In so-doing, we setup
the iOS app developers for success by removing the need to maintain a thorough
understanding of the Apple ecosystem's intense audio implementation requirements.

The code in this package is meant to be relatively static and unchanging. If we
need to make any modifications to this package, it is because we have expanded
our application's business requirements such that new standards must now be
achieved, or because Apple's own internal standards/requirements have been
changed.

### Development
All changes to this library, once implemented into Chat by Storyboard for iOS,
will be required to go through code review via GitHub pull request.

## Usage Guide

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
> TBD

### Using the `PlaybackManager`
The best way to access and utilize our playback tools is via `AudioConductor.playerMan`.

You must utilize this manager in order to get access to the class-managed timing
metadata needed for UI relating to playback progress.

***NEVER use a `Timer` or `Date` to do anything related to playback time
tracking!!*** Instead, read on to learn how to access the class-managed values.

#### Time Metadata for UI
We publish time elapsed in seconds at [`PlaybackManager.currentTimeString`](https://github.com/Storyboard-fm/ChatKit/blob/341a4cef5cd8133b9d29391c32722c68f42e1566/Sources/ChatKit2/Audio/PlaybackManager.swift#L33).

We also publish the float used to increment playback progress at [`PlaybackManager.currentProgress`](https://github.com/Storyboard-fm/ChatKit/blob/341a4cef5cd8133b9d29391c32722c68f42e1566/Sources/ChatKit2/Audio/PlaybackManager.swift#L27).

## Examples

### Create and play a new `Message`

```swift
let fileURL: URL = // get local file URL somehow...
let msg = Message(audioFile: AVAudioFile(forReading: fileURL))
try conductor.playerMan.newLocalMessage(msg: msg)
```
