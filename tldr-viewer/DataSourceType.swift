//
//  DataSourceType.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

protocol DataSourceType {
    var name: String { get }
    var type: Preferences.DataSourceEnumType { get }
    
    // callback signal from the DataSource when data has changed
    var updateSignal: () -> Void { get set }
    
    // all the known commands
    func allCommands() -> [Command]
    
    // all commands shown in the default list (this may have some plstform-specific stuff removed)
    func allListableCommands() -> [Command]
}
