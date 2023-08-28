//
//  File.swift
//  
//
//  Created by Andrew Grathwohl on 8/28/23.
//

import Foundation

public final class Me {
    let accountId: String
    let locale: Locale
    let preferredLocale: String
    public init(accountId: String="", locale: Locale=Locale(identifier: "en-US")) {
        self.accountId = accountId
        self.locale = locale
        self.preferredLocale = Bundle.main.preferredLocalizations.first ?? locale.identifier
    }
}
