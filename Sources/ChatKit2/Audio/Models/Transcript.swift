//
//  Transcript.swift
//  
//
//  Created by Andrew Grathwohl on 8/24/23.
//

import MediaPlayer

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
