//
//  DataSourcing.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

protocol DataSourceDelegate {
    func dataSourceDidUpdate(dataSource: DataSourcing)
}

protocol DataSourcing: class {
    var commands: [Command] { get }
    
    // TODO: isSearchable/isRefreshable might be better as an OptionSet
    var isSearchable: Bool { get }
    var isRefreshable: Bool { get }
    
    // callback from the DataSource when data has changed
    func add(delegate: DataSourceDelegate)
}
