//
//  Preferences.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 22/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

class Preferences {
    enum DataSourceEnumType: String {
        case all = "all"
        case favourites = "favourites"
    }
    
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
    
    func currentDataSource() -> DataSourceEnumType {
        guard let rawValue = userDefaults.string(forKey: Constant.PreferenceKey.selectedDataSource) else { return .all }
        guard let result = DataSourceEnumType(rawValue: rawValue) else { return .all }
        return result
    }
    
    func setCurrentDataSource(_ dataSource: DataSourceEnumType) {
        userDefaults.set(dataSource.rawValue, forKey: Constant.PreferenceKey.selectedDataSource)
        userDefaults.synchronize()
    }
    
    func favouriteCommandNames() -> [String] {
        guard let result = userDefaults.stringArray(forKey: Constant.PreferenceKey.favouriteCommandNames) else { return [] }
        return result
    }
    
    func setFavouriteCommandNames(_ favouriteCommandNames: [String]) {
        userDefaults.set(favouriteCommandNames, forKey:Constant.PreferenceKey.favouriteCommandNames)
        userDefaults.synchronize()
    }
}
