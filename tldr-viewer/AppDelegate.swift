//
//  AppDelegate.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit
import CoreSpotlight
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        Theme.setup()
        
        return true
    }
    
    // MARK: - NSUserActivity (Spotlight) stuff
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let commandName = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return false }
        postNotification(commandName)
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let userInfo = shortcutItem.userInfo else { return }
        guard let commandName = userInfo[Constant.Shortcut.commandNameKey] as? String else { return }
        postNotification(commandName)
        // TODO: completionHandler?
    }
    
    func postNotification(_ commandName: String) {
        // yuck!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: Constant.ExternalCommandChangeNotification.name, object: nil, userInfo: [Constant.ExternalCommandChangeNotification.commandNameKey : commandName as NSSecureCoding])
        }
    }
}

