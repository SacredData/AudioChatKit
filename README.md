# ChatKit2
> Storyboard's iOS audio toolkit

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

- Category: `.playback`
- Mode: `.spokenAudio`
- Policy: `.longFormAudio`

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

## Examples

### Create and play a new `Message`

```swift
let fileURL: URL = // get local file URL somehow...
let msg = Message(audioFile: AVAudioFile(forReading: fileURL))
try conductor.playerMan.newLocalMessage(msg: msg)
```
