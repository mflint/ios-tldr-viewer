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
}

extension Command: Comparable {
    static func < (lhs: Command, rhs: Command) -> Bool {
        return lhs.name < rhs.name
    }
}
