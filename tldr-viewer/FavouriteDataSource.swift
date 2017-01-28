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
        NotificationCenter.default.post(name: Constant.FavouriteChangeNotification.name, object:self)
    }
}
