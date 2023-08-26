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
    let creator: String
    var members: [String]
    var messages: [Message]?
    public init(id: String, name: String, teamCreator: String) {
        self.feedId = id
        self.teamName = name
        self.creator = teamCreator
        members = [teamCreator]
    }
}
