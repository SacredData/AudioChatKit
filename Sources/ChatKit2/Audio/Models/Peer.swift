//
//  Peer.swift
//  
//
//  Created by Andrew Grathwohl on 8/26/23.
//

import Foundation
import MultipeerConnectivity

public final class Peer {
    let peerId: MCPeerID
    let name: String
    var teams: [Team]?
    // TODO: Use a more appropriate type definition
    let phoneNumber: String?
    let emailAddress: String?
    public init(id: MCPeerID, name: String, teams: [Team], phoneNumber: String?, emailAddress: String?) {
        self.peerId = id
        self.name = name
        self.teams = teams
        self.phoneNumber = phoneNumber ?? ""
        self.emailAddress = emailAddress ?? ""
    }
}
