//
//  Command.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

struct Command: Codable {
    let name: String
    var variants = [CommandVariant]()

    // TODO: change this signature to match sort(by areInIncreasingOrder: (Element, Element) throws -> Bool)
    static func sort(commands: [Command]) -> [Command] {
        return commands.sorted(by: { (first, second) -> Bool in
            return first.name.compare(second.name) == ComparisonResult.orderedAscending
        })
    }
}

extension Command: Comparable {
    static func < (lhs: Command, rhs: Command) -> Bool {
        return lhs.name < rhs.name
    }
}
