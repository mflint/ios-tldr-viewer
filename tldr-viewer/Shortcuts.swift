//
//  Shortcuts.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 22/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation
import UIKit

class Shortcuts {
    /// recreate dynamic quick actions, which appear when 3D-touching the
    /// app icon on the home screen. This makes actions for the most recently
    /// viewed commands
    class func recreate() {
        var shortcutItems: [UIApplicationShortcutItem] = []
        for commandName in Preferences.sharedInstance.latest().makeIterator() {
            let shortcutItem = UIMutableApplicationShortcutItem(type: "", localizedTitle: commandName)
            
            // TODO: handle duplicate commands
            // TODO: this should show the summary from the correct variant, not the first variant
            if let command = DataSource.sharedInstance.commandsWith(name: commandName).first,
                let commandVariant = command.variants.first {
                shortcutItem.localizedSubtitle = commandVariant.summary()
                
                shortcutItem.icon = UIApplicationShortcutIcon(type: .favorite)
                shortcutItem.userInfo = [Constant.Shortcut.commandNameKey: commandName as NSString]
                shortcutItems.insert(shortcutItem, at: 0)
            }
        }
        
        UIApplication.shared.shortcutItems = shortcutItems
    }
}
