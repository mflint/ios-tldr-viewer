//
//  CommandCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

struct CommandCellViewModel: BaseCellViewModel {
    var command: Command
    
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    var commandText: NSAttributedString!
    var platforms: NSAttributedString!
    
    init(command: Command, action: @escaping ViewModelAction) {
        self.command = command
        
        self.cellIdentifier = "CommandCell"
        self.action = action
        
        self.commandText = Theme.bodyAttributed(string: command.name)
        
        var platformString: String!
        if let platforms = command.platforms {
            let platformNames = platforms.map({ (platform) -> String in
                return platform.displayName
            })
            
            switch platformNames.count {
            case 0:
                platformString = ""
            case 1:
                platformString = Localizations.CommandList.CommandPlatforms.One(value1: platformNames[0])
            case 2:
                platformString = Localizations.CommandList.CommandPlatforms.Two(value1: platformNames[0], platformNames[1])
            case 3:
                platformString = Localizations.CommandList.CommandPlatforms.Three(value1: platformNames[0], platformNames[1], platformNames[2])
            default:
                platformString = Localizations.CommandList.CommandPlatforms.Four(value1: platformNames[0], platformNames[1], platformNames[2], platformNames[3])
            }
        } else {
            platformString = ""
        }
        
        self.platforms = Theme.detailAttributed(string: platformString)
    }
    
    func performAction() {
        self.action()
    }
}
