//
//  FavouriteDataSource.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

public class FavouriteDataSource: DataSourceType {
    // no-op closures until the ViewModel provides its own
    var updateSignal: () -> Void = {}

    static let sharedInstance = FavouriteDataSource()
    let name = "Favourites"
    let type = Preferences.DataSourceEnumType.favourites
    
    private let dataSource = DataSource.sharedInstance
    var favouriteCommandNames = Preferences.sharedInstance.favouriteCommandNames()
    
    private init() {
        let keyValueStore = NSUbiquitousKeyValueStore.default()
        NotificationCenter.default.addObserver(self, selector: #selector(FavouriteDataSource.onCloudKeyValueStoreUpdate), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: keyValueStore)
        keyValueStore.synchronize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func onCloudKeyValueStoreUpdate(notification: Notification) {
        guard let changeReason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
        guard let changedKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        
        if changeReason == NSUbiquitousKeyValueStoreInitialSyncChange || changeReason == NSUbiquitousKeyValueStoreServerChange && changedKeys.contains(Constant.iCloudKey.favouriteCommandNames) {
            let keyValueStore = NSUbiquitousKeyValueStore.default()
            if let incomingFavouriteNames = keyValueStore.array(forKey: Constant.iCloudKey.favouriteCommandNames) as? [String] {
                favouriteCommandNames = incomingFavouriteNames
                postNotification()
            }
        }
    }
    
    func allCommands() -> [Command] {
        return dataSource.commandsWith(filter: { (command) -> Bool in
            return favouriteCommandNames.contains(command.name)
        })
    }
    
    func add(commandName: String) {
        favouriteCommandNames.append(commandName)
        favouriteCommandNames.sort()
        save()
    }
    
    func remove(commandName: String) {
        if let index = favouriteCommandNames.index(of: commandName) {
            favouriteCommandNames.remove(at: index)
            save()
        }
    }
    
    private func save() {
        Preferences.sharedInstance.setFavouriteCommandNames(favouriteCommandNames)
        
        let keyValueStore = NSUbiquitousKeyValueStore.default()
        keyValueStore.set(favouriteCommandNames, forKey: Constant.iCloudKey.favouriteCommandNames)
        keyValueStore.synchronize()
        
        postNotification()
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: Constant.FavouriteChangeNotification.name, object:self)
    }
}
