//
//  NoResultsCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 23/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

struct NoResultsCellViewModel: BaseCellViewModel, MessageAndButtonCellViewModel {
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    var labelText: NSAttributedString!
    var buttonText: String!
    
    init(buttonAction: @escaping ViewModelAction) {
        self.cellIdentifier = "MessageAndButtonCell"
        self.action = buttonAction
        
        let labelText = NSMutableAttributedString(attributedString: Theme.detailAttributed(string: "Nothing found!\n\n")!)
        labelText.append(Theme.bodyAttributed(string: "tldr")!)
        labelText.append(Theme.detailAttributed(string: " is a community effort, and relies on people like you to contribute content.\n")!)
        
        self.labelText = labelText
        self.buttonText = "Contribute new content"
    }
    
    func performAction() {
        // no-op
    }
    
    func performButtonAction() {
        self.action()
    }
}
