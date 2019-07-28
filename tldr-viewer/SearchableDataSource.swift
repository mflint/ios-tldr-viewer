//
//  SearchableDataSource.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

protocol SearchableDataSource {
    /// find Commands with this exact name
    func commandsWith(name: String) -> [Command]
    
    /// find Commands whose name matches a filter
    func commandsWith(filterString: String) -> [Command]
}
