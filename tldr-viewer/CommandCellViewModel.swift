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
    
    var command: Command
    
    var cellIdentifier: String!
    var action: CellViewModelAction = {}
    
    var commandText: NSAttributedString!
    var platforms: NSAttributedString!
    
    init(command: Command, action: CellViewModelAction) {
        self.command = command
        
        self.cellIdentifier = "CommandCell"
        self.action = action
        
        self.commandText = Theme.bodyAttributed(command.name)
        
        var platforms = ""
        for (index, platform) in command.platforms.enumerate() {
            platforms += platform.displayName
            if (index < command.platforms.count - 1) {
                platforms += ", "
            }
        }
        
        self.platforms = Theme.detailAttributed(platforms)
    }
    
    func performAction() {
        self.action()
    }
}