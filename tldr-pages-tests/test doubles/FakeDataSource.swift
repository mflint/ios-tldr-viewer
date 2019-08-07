//
//  FakeDataSource.swift
//  tldr-pages-tests
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation
@testable import tldr_viewer

class FakeDataSource: DataSourcing {
    private var delegates = WeakCollection<DataSourceDelegate>()
    
    var commands: [Command]
    
    var isSearchable = false
    
    var isRefreshable = false
    
    init(_ commands: [Command]) {
        self.commands = commands
    }
    
    init(_ command: Command) {
        commands = [command]
    }
    
    func add(delegate: DataSourceDelegate) {
        delegates.add(delegate)
    }
    
    func triggerUpdate() {
        delegates.forEach { (delegate) in
            delegate.dataSourceDidUpdate(dataSource: self)
        }
    }
}
