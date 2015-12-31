//
//  CommandCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

struct CommandCellViewModel: BaseCellViewModel {
    typealias CellViewModelAction = () -> Void
    
    var cellIdentifier: String!
    var action: CellViewModelAction = {}
    
    var commandText: String!
    var platforms: String!
    
    init(command: Command, action: CellViewModelAction) {
        self.cellIdentifier = "CommandCell"
        self.action = action
        
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
    
    func performAction() {
        self.action()
    }
}