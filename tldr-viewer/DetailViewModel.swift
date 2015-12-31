//
//  DetailViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

class DetailViewModel {
    var detailAttributedText: NSAttributedString
    private var command: Command!
    
    init(command: Command) {
        self.command = command
        self.detailAttributedText = NSAttributedString.init(string: self.command.name)
    }
}