//
//  Preferences.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 22/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

class Preferences {
    static let sharedInstance = Preferences()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        let latest = userDefaults.stringArray(forKey: Constant.PreferenceKey.latest)
        if latest == nil {
            let empty: [String] = []
            userDefaults.set(empty, forKey: Constant.PreferenceKey.latest)
        }
    }
    
    func latest() -> [String] {
        return userDefaults.stringArray(forKey: Constant.PreferenceKey.latest)!
    }
    
    func addLatest(_ newEntry: String) {
        var latest = userDefaults.stringArray(forKey: Constant.PreferenceKey.latest)!
        
        let indexOfExistingEntry = latest.index(of: newEntry)
        if let indexOfExistingEntry = indexOfExistingEntry {
            latest.remove(at: indexOfExistingEntry)
        }
        
        latest.append(newEntry)
        
        if latest.count > Constant.Shortcut.count {
            latest.removeFirst()
        }
        
        userDefaults.set(latest, forKey: Constant.PreferenceKey.latest)
    }
}
