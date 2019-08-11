//
//  FavouriteDataSourceDecorator.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

class FavouriteDataSourceDecorator: DataSourcing, SwitchableDataSourceDecorator {
    private var underlyingDataSource: DataSourcing
    private(set) var commands = [Command]()
    
    let isSearchable = false
    let isRefreshable = false
    
    let name = Localizations.CommandList.DataSources.Favourites
    let type = DataSourceType.favourites

    private var delegates = WeakCollection<DataSourceDelegate>()

    var favouriteCommandNames: [String] {
        didSet {
            update()
            
            // save to preferences/iCloud in the background
            DispatchQueue.global().async {
                self.save()
            }
        }
    }
    
    init(underlyingDataSource: DataSourcing) {
        // default value comes from local Preferences
        favouriteCommandNames = Preferences.sharedInstance.favouriteCommandNames()
        
        self.underlyingDataSource = underlyingDataSource
        underlyingDataSource.add(delegate: self)
        
        // listen for iCloud updates
        let keyValueStore = NSUbiquitousKeyValueStore.default
        NotificationCenter.default.addObserver(self, selector: #selector(FavouriteDataSourceDecorator.onCloudKeyValueStoreUpdate), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: keyValueStore)
        keyValueStore.synchronize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func add(delegate: DataSourceDelegate) {
        delegates.add(delegate)
    }
    
    @objc private func onCloudKeyValueStoreUpdate(notification: Notification) {
        guard let changeReason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
        guard let changedKeys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        
        if changeReason == NSUbiquitousKeyValueStoreInitialSyncChange || changeReason == NSUbiquitousKeyValueStoreServerChange && changedKeys.contains(Constant.iCloudKey.favouriteCommandNames) {
            let keyValueStore = NSUbiquitousKeyValueStore.default
            if let incomingFavouriteNames = keyValueStore.array(forKey: Constant.iCloudKey.favouriteCommandNames) as? [String] {
                favouriteCommandNames = incomingFavouriteNames
            }
        }
    }
    
    func add(commandName: String) {
        favouriteCommandNames.append(commandName)
    }
    
    func remove(commandName: String) {
        if let index = favouriteCommandNames.firstIndex(of: commandName) {
            favouriteCommandNames.remove(at: index)
        }
    }
    
    func isFavourite(commandName: String) -> Bool {
        favouriteCommandNames.contains(commandName)
    }
    
    private func save() {
        Preferences.sharedInstance.setFavouriteCommandNames(favouriteCommandNames)
        
        postNotification()
        
        let keyValueStore = NSUbiquitousKeyValueStore.default
        keyValueStore.set(favouriteCommandNames, forKey: Constant.iCloudKey.favouriteCommandNames)
        keyValueStore.synchronize()
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: Constant.FavouriteChangeNotification.name, object:self)
    }
    
    private func update() {
        commands = underlyingDataSource.commands.filter({ (command) -> Bool in
            self.isFavourite(commandName: command.name)
        })
        
        delegates.forEach { (delegate) in
            delegate.dataSourceDidUpdate(dataSource: self)
        }
    }
}

extension FavouriteDataSourceDecorator: DataSourceDelegate {
    func dataSourceDidUpdate(dataSource: DataSourcing) {
        update()
    }
}
