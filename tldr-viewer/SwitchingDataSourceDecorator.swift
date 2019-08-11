//
//  SwitchingDataSourceDecorator.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

// TODO: this doesn't need to be an enum
enum DataSourceType: String {
    case all
    case favourites
}

protocol SwitchableDataSourceDecorator: DataSourcing {
    var name: String { get }
    var type: DataSourceType { get }
}

class SwitchingDataSourceDecorator: DataSourcing {
    private(set) var underlyingDataSources: [SwitchableDataSourceDecorator]
    private var delegates = WeakCollection<DataSourceDelegate>()
    private(set) var commands = [Command]()
    
    var isSearchable: Bool {
        return underlyingDataSources[selectedDataSourceIndex].isSearchable
    }
    
    var isRefreshable: Bool {
        return underlyingDataSources[selectedDataSourceIndex].isRefreshable
    }
    
    var selectedDataSourceIndex = 0 {
        didSet {
            update()
            Preferences.sharedInstance.setCurrentDataSource(underlyingDataSources[selectedDataSourceIndex].type)
        }
    }
    
    var selectedDataSourceType: DataSourceType {
        return underlyingDataSources[selectedDataSourceIndex].type
    }
    
    init(underlyingDataSources: [SwitchableDataSourceDecorator]) {
        self.underlyingDataSources = underlyingDataSources
        
        underlyingDataSources.forEach { (dataSource) in
            dataSource.add(delegate: self)
        }
        
        let currentDataSourceType = Preferences.sharedInstance.currentDataSource()
        for (index, dataSource) in underlyingDataSources.enumerated() {
            if currentDataSourceType == dataSource.type {
                selectedDataSourceIndex = index
            }
        }
    }
    
    func add(delegate: DataSourceDelegate) {
        delegates.add(delegate)
    }
    
    private func update() {
        commands = underlyingDataSources[selectedDataSourceIndex].commands
        delegates.forEach { (delegate) in
            delegate.dataSourceDidUpdate(dataSource: self)
        }
    }
}

extension SwitchingDataSourceDecorator: DataSourceDelegate {
    func dataSourceDidUpdate(dataSource: DataSourcing) {
        if let selectableDataSource = dataSource as? SwitchableDataSourceDecorator,
            selectableDataSource.type == selectedDataSourceType {
            update()
        }
    }
}
