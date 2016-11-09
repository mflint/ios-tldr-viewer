//
//  ErrorCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

struct ErrorCellViewModel: BaseCellViewModel, MessageAndButtonCellViewModel {
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    var labelText: NSAttributedString!
    var buttonText: String!
    
    init(errorText: String, buttonAction: @escaping ViewModelAction) {
        self.cellIdentifier = "MessageAndButtonCell"
        self.action = buttonAction
        self.labelText = Theme.detailAttributed(string: errorText)
        self.buttonText = "Try again"
    }
    
    func performAction() {
        // no-op
    }
    
    func performButtonAction() {
        self.action()
    }
}
