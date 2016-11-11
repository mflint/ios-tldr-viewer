//
//  Command.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

struct Command {
    let name: String!
    let platforms: [Platform]!
    
    static func sort(commands: [Command]) -> [Command] {
        return commands.sorted(by: { (first, second) -> Bool in
            return first.name.compare(second.name) == ComparisonResult.orderedAscending
        })
    }
}
