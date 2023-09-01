//
//  Peer.swift
//  
//
//  Created by Andrew Grathwohl on 8/26/23.
//

import Foundation
import MultipeerConnectivity

public final class Peer {
    let me: Bool
    let peerId: String?
    let name: String?
    var teams: [Team]?
    // TODO: Use PhoneNumberKit
    let phoneNumber: String?
    let emailAddress: String?
    let locale: Locale?
    public init(id: String?, name: String?, teams: [Team]?, locale: Locale?, phoneNumber: String?, emailAddress: String?, me: Bool=false) {
        self.me = me // Is this the user logged-in to the app?
        self.peerId = id
        self.locale = locale ?? Locale(identifier: "en-US")
        self.name = name
        self.teams = teams
        self.phoneNumber = phoneNumber ?? ""
        self.emailAddress = emailAddress ?? ""
    }
}
