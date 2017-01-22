//
//  AppDelegate.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        Theme.setup()
        
        return true
    }
    
    // MARK: - NSUserActivity stuff
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let topViewController = topViewController() {
            // topViewController is a ListViewController
            topViewController.restoreUserActivityState(userActivity)
        }
        
        return true
    }
    
    func topViewController() -> UIViewController? {
        let splitController = self.window?.rootViewController as! UISplitViewController
        let navigationController = splitController.viewControllers.first as! UINavigationController
        var topViewController = navigationController.topViewController
        if let nav = topViewController as? UINavigationController {
            topViewController = nav.topViewController
        }
        return topViewController
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let topViewController = topViewController() as? ShortcutHandler {
            topViewController.handleShortcutItem(shortcutItem)
        }
    }
}

