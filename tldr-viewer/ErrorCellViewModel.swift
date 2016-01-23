//
//  ErrorCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

struct ErrorCellViewModel: BaseCellViewModel {
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    var errorText: NSAttributedString!
    var buttonText: String!
    
    init(errorText: String, buttonAction: ViewModelAction) {
        self.cellIdentifier = "ErrorCell"
        self.action = buttonAction
        self.errorText = Theme.detailAttributed(errorText)
        self.buttonText = "Try again"
    }
    
    func performAction() {
        // no-op
    }
    
    func performButtonAction() {
        self.action()
    }
}