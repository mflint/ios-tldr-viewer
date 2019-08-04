//
//  DataSources.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

class DataSources {
    static let sharedInstance = DataSources()
    
    /// this `baseDataSource` holds _all_ the Commands
    let baseDataSource: DataSource
    
    /// `filteredDataSource` applies high-level filters to the list of Commands, removing
    /// Commands that the user never wants to see. (Hidden platforms, user's locale, etc)
    let filteredDataSource: FilteringDataSourceDecorator
    
    /// `searchingDataSource` allows the user to search the list of Commands
    let searchingDataSource: SearchingDataSourceDecorator
    
    /// `favouritesDataSource` is a list of the user's favourite Commands
    let favouritesDataSource: FavouriteDataSourceDecorator
    
    /// `switchingDataSource` drives the segmented-control on the Command List screen,
    /// switching between `searchingDataSource` and `favouritesDataSource`
    let switchingDataSource: SwitchingDataSourceDecorator

    private init() {
        baseDataSource = DataSource()
        filteredDataSource = FilteringDataSourceDecorator(underlyingDataSource: baseDataSource)
        searchingDataSource = SearchingDataSourceDecorator(underlyingDataSource: filteredDataSource)
        favouritesDataSource = FavouriteDataSourceDecorator(underlyingDataSource: filteredDataSource)
        switchingDataSource = SwitchingDataSourceDecorator(underlyingDataSources: [searchingDataSource, favouritesDataSource])
    }
}
