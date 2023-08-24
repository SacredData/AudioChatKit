//
//  Transcript.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import MediaPlayer

/// A model of the transcript of the original spoken audio in the message.
/// Attaching this to a `Message` also sets that message's spoken language.
final class Transcript: ObservableObject {
    let text: String
    let languageOption: MPNowPlayingInfoLanguageOption
    init(text: String="", displayName: String="", identifier: String="", languageTag: String="") {
        self.text = text
        self.languageOption = MPNowPlayingInfoLanguageOption.init(
            type: .legible,
            languageTag: languageTag,
            characteristics: [
                MPLanguageOptionCharacteristicVoiceOverTranslation,
                MPLanguageOptionCharacteristicTranscribesSpokenDialog
            ],
            displayName: displayName,
            identifier: identifier)
    }
}

/// Any additional translations of the original `Transcript` attached to a `Message`
final class Translation: ObservableObject {
    let originalTranscript: Transcript
    let languageOption: MPNowPlayingInfoLanguageOption
    init(transcript: Transcript, text: String="", displayName: String="", identifier: String="", languageTag: String="") {
        self.originalTranscript = transcript
        self.languageOption = MPNowPlayingInfoLanguageOption.init(
            type: .legible,
            languageTag: languageTag,
            characteristics: [
                MPLanguageOptionCharacteristicLanguageTranslation,
                MPLanguageOptionCharacteristicVoiceOverTranslation,
                MPLanguageOptionCharacteristicTranscribesSpokenDialog
            ],
            displayName: displayName,
            identifier: identifier)
    }
}
