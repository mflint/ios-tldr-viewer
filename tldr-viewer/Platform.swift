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
    
    // in the API, the platforms are in alphabetic order so "linux" comes before "osx". I'm setting a different order here ("common" first, followed by "osx", then alphabetic afterwards) to appease the AppStore Review Gods
    static let sortRule = { (first: Platform, second: Platform) -> Bool in
        if first.name == "common" { return true }
        if second.name == "common" { return false }
        if first.name == "osx" { return true }
        if second.name == "osx" { return false }
        return first.name.compare(second.name) == ComparisonResult.orderedAscending
    }

    
    // this maps API platform names to display names. Anything not in this list will be capitalized
    private static let platformMapping = [
        "osx": Localizations.CommandList.CommandPlatform.Osx,
        "sunos": Localizations.CommandList.CommandPlatform.Solaris,
        "linux": Localizations.CommandList.CommandPlatform.Linux,
        "common": Localizations.CommandList.CommandPlatform.Common
    ]
    
    static var platforms: [String:Platform] = [:]
    
    private init(name: String) {
        self.name = name
        
        if let mapped = Platform.platformMapping[name] {
            self.displayName = mapped
        } else {
            self.displayName = name.capitalized
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
    
    class func sort(platforms: [Platform]) -> [Platform] {
        return platforms.sorted(by: sortRule)
    }
}
