//
//  Constants.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 22/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

struct Constant {
    
    struct PreferenceKey {
        static let latest = "latest"
    }
    
    struct Shortcut {
        static let count = 4
        static let commandNameKey = "commandName"
    }
    
    struct CommandChangeNotification {
        static let name = Notification.Name("commandChangeNotification")
        static let commandNameKey = "commandName"
    }
}
