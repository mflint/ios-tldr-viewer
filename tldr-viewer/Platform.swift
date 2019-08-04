//
//  CommandPlatform.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

struct Platform: Codable {
    var name: String
    var displayName: String
    var sortOrder: Int
    
    private static var platforms = [
        "common": Platform(name: "common", displayName: Localizations.CommandList.CommandPlatform.Common, sortOrder: 0),
        "osx": Platform(name: "osx", displayName: Localizations.CommandList.CommandPlatform.Osx, sortOrder: 1),
        "linux": Platform(name: "linux", displayName: Localizations.CommandList.CommandPlatform.Linux, sortOrder: 2),
        "sunos": Platform(name: "sunos", displayName: Localizations.CommandList.CommandPlatform.Solaris, sortOrder: 3),
        "windows": Platform(name: "windows", displayName: Localizations.CommandList.CommandPlatform.Windows, sortOrder: 4)
    ]
    
    private init(name: String, displayName: String, sortOrder: Int) {
        self.name = name
        self.displayName = displayName
        self.sortOrder = sortOrder
    }
    
    static func get(name: String) -> Platform {
        var platform = Platform.platforms[name]
        if (platform == nil) {
            platform = platforms[name, default: Platform(name: name, displayName: name.capitalized, sortOrder: platforms.count)]
            Platform.platforms[name] = platform
        }
        
        return platform!
    }
}

extension Platform: Comparable {
    static func < (lhs: Platform, rhs: Platform) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}
