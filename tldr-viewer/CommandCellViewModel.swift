//
//  CommandCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

struct CommandCellViewModel: BaseCellViewModel {
    var cellIdentifier: String!
    var commandText: String!
    var platforms: String!
    
    init(command: Command) {
        self.cellIdentifier = "CommandCell"
        self.commandText = command.name
        
        var platforms = ""
        for (index, platform) in command.platforms.enumerate() {
            platforms += platform
            if (index < command.platforms.count - 1) {
                platforms += ", "
            }
        }
        
        self.platforms = platforms
    }
}