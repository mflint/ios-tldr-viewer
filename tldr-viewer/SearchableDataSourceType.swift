//
//  SearchableDataSourceType.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

protocol SearchableDataSourceType {
    // find a Command or Commands with some criteria, from the complete set
    func commandWith(name: String) -> Command?
    func commandsWith(filter: (Command) -> Bool) -> [Command]
    
    // find a Command or Commands with a filter, from the listable set
    // (listable set is pre-filtered by platform)
    func listableCommandsWith(filter: String) -> [Command]
}
