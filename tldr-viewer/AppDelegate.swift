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
        let splitController = self.window?.rootViewController as! UISplitViewController
        let navigationController = splitController.viewControllers.first as! UINavigationController
        if let topViewController = navigationController.topViewController {
            // topViewController is a ListViewController
            topViewController.restoreUserActivityState(userActivity)
        }
        
        return true
    }
}

