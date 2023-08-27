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
    let peerId: MCPeerID
    let name: String
    var teams: [Team]?
    // TODO: Use PhoneNumberKit
    let phoneNumber: String?
    let emailAddress: String?
    public init(id: MCPeerID, name: String, me: Bool=false, teams: [Team], phoneNumber: String?, emailAddress: String?) {
        self.me = me // Is this the user logged-in to the app?
        self.peerId = id
        self.name = name
        self.teams = teams
        self.phoneNumber = phoneNumber ?? ""
        self.emailAddress = emailAddress ?? ""
    }
}
