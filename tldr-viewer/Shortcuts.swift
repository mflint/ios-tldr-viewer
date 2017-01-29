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
    class func recreate() {
        var shortcutItems: [UIApplicationShortcutItem] = []
        for commandName in Preferences.sharedInstance.latest().makeIterator() {
            let shortcutItem = UIMutableApplicationShortcutItem(type: "", localizedTitle: commandName)
            
            if let command = DataSource.sharedInstance.commandWith(name: commandName) {
                shortcutItem.localizedSubtitle = command.summary()
            }
            
            shortcutItem.icon = UIApplicationShortcutIcon(type: .favorite)
            shortcutItem.userInfo = [Constant.Shortcut.commandNameKey: commandName as NSString]
            shortcutItems.insert(shortcutItem, at: 0)
        }
        
        UIApplication.shared.shortcutItems = shortcutItems
    }
}
