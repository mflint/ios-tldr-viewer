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
        
        let indexOfExistingEntry = latest.firstIndex(of: newEntry)
        if let indexOfExistingEntry = indexOfExistingEntry {
            latest.remove(at: indexOfExistingEntry)
        }
        
        latest.append(newEntry)
        
        if latest.count > Constant.Shortcut.count {
            latest.removeFirst()
        }
        
        userDefaults.set(latest, forKey: Constant.PreferenceKey.latest)
    }
    
    func currentDataSource() -> DataSourceType {
        guard let rawValue = userDefaults.string(forKey: Constant.PreferenceKey.selectedDataSource) else { return .all }
        guard let result = DataSourceType(rawValue: rawValue) else { return .all }
        return result
    }
    
    func setCurrentDataSource(_ dataSource: DataSourceType) {
        userDefaults.set(dataSource.rawValue, forKey: Constant.PreferenceKey.selectedDataSource)
        userDefaults.synchronize()
    }
    
    func favouriteCommandNames() -> [String] {
        switch userDefaults.value(forKey: Constant.PreferenceKey.favouriteCommandNames) {
        case let stringArray as [String]:
            return stringArray
        case let string as String:
            // when XCUITests run, for creating screenshots, favourites are passed into
            // the argument domain as a comma separated string
            return string.components(separatedBy: ",")
        default:
            return []
        }
    }
    
    func setFavouriteCommandNames(_ favouriteCommandNames: [String]) {
        userDefaults.set(favouriteCommandNames, forKey:Constant.PreferenceKey.favouriteCommandNames)
        userDefaults.synchronize()
    }
}
