//
//  FilteringDataSourceDecorator.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 03/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

/// This DataSource Decorator filters out Commands based on
/// the user's locale and preferred Platforms
class FilteringDataSourceDecorator: DataSourcing {
    private let commandNameBlackList = ["fuck"] // this is a family show
    private var underlyingDataSource: DataSourcing
    
    private var delegates = WeakCollection<DataSourceDelegate>()
    private(set) var commands = [Command]()
    
    var isSearchable: Bool {
        return underlyingDataSource.isSearchable
    }
    
    var isRefreshable: Bool {
        return underlyingDataSource.isRefreshable
    }

    init(underlyingDataSource: DataSourcing) {
        self.underlyingDataSource = underlyingDataSource
        underlyingDataSource.add(delegate: self)
    }
    
    func add(delegate: DataSourceDelegate) {
        delegates.add(delegate)
    }

    private func update() {
        // TODO: platform and locale filtering first
        commands = underlyingDataSource.commands.filter({ (command) -> Bool in
            return !commandNameBlackList.contains(command.name)
        })
        
        delegates.forEach { (delegate) in
            delegate.dataSourceDidUpdate(dataSource: self)
        }
    }
}

extension FilteringDataSourceDecorator: DataSourceDelegate {
    func dataSourceDidUpdate(dataSource: DataSourcing) {
        update()
    }
}
