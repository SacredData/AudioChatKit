//
//  Team.swift
//  
//
//  Created by Andrew Grathwohl on 8/26/23.
//

import Foundation

public final class Team {
    let teamName: String
    let feedId: String
    let creator: Peer
    var members: [Peer]
    var messages: [Message]?
    public init(id: String, name: String, teamCreator: Peer) {
        self.feedId = id
        self.teamName = name
        self.creator = teamCreator
        members = [teamCreator]
    }
    public func addMembers(members: [Peer]) {
        self.members.append(contentsOf: members)
    }
    public func removeMembers(members: [Peer]) {
        self.members.removeAll(where: {
            let pid = $0.peerId
            return members.contains(where: {$0.peerId == pid})
        })
    }
    public func addMessages(messages: [Message]) {
        self.messages?.append(contentsOf: messages)
    }
}
