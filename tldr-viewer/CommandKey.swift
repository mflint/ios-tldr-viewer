//
//  CommandKey.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 28/07/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

struct CommandKey{
    /// the name of the command
    let commandName: String
    
    /// the name of the platform
    let platformName: String?
}

extension CommandKey {
    private static let separator: Character = "🦌"
    
    public init(_ value: String) {
        let components = value.split(separator: CommandKey.separator)
        
        guard let commandName = components.first else {
            preconditionFailure("no command name in CommandKey value")
        }
        self.commandName = String(commandName)
        
        platformName = components.count > 1 ? String(components[1]) : nil
    }
}

extension CommandKey: CustomStringConvertible {
    var description: String {
        get {
            if let platformName = platformName {
                return "\(commandName)\(CommandKey.separator)\(platformName)"
            }
            
            return commandName
        }
    }
}

extension CommandKey: Codable, Equatable {}
