//
//  Platform.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

class Platform {
    var name: String
    var displayName: String
    
    // this maps API platform names to display names. Anything not in this list will be capitalized
    private static let platformMapping = [
        "osx": "OS X",
        "sunos": "Solaris"
    ]
    
    private static var platforms: [String:Platform] = [:]
    
    private init(name: String) {
        self.name = name
        
        if let mapped = Platform.platformMapping[name] {
            self.displayName = mapped
        } else {
            self.displayName = name.capitalizedString
        }
    }
    
    class func get(name: String) -> Platform {
        var platform = Platform.platforms[name]
        if (platform == nil) {
            platform = Platform(name: name)
            Platform.platforms[name] = platform
        }
        
        return platform!
    }
}