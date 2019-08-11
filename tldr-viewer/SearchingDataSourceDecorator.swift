//
//  SearchingDataSourceDecorator.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

class SearchingDataSourceDecorator: DataSourcing, SwitchableDataSourceDecorator {
    private var delegates = WeakCollection<DataSourceDelegate>()
    
    private(set) var commands = [Command]() {
        didSet {
            delegates.forEach { (delegate) in
                delegate.dataSourceDidUpdate(dataSource: self)
            }
        }
    }
    
    var searchText: String = "" {
        didSet {
            update()
        }
    }
    
    let isSearchable = true
    
    var isRefreshable: Bool {
        return underlyingDataSource.isRefreshable
    }
    
    private var underlyingDataSource: DataSourcing
    
    let name = Localizations.CommandList.DataSources.All
    let type = DataSourceType.all

    init(underlyingDataSource: DataSourcing) {
        self.underlyingDataSource = underlyingDataSource
        underlyingDataSource.add(delegate: self)
    }
    
    func add(delegate: DataSourceDelegate) {
        delegates.add(delegate)
    }
    
    private func update() {
        let allCommands = underlyingDataSource.commands
        
        // if the search string is empty, return everything
        if searchText.isEmpty {
            commands = allCommands
        } else {
            let lowercasedSearchText = searchText.lowercased()
            commands = allCommands.filter({ (command) -> Bool in
                // TODO: can improve search performance by adding `lowercasedName`
                // property to Command
                command.name.lowercased().contains(lowercasedSearchText)
            })
        }
    }
}

extension SearchingDataSourceDecorator: DataSourceDelegate {
    func dataSourceDidUpdate(dataSource: DataSourcing) {
        update()
    }
}
