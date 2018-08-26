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
    
    init(searchTerm: String, buttonAction: @escaping ViewModelAction) {
        self.cellIdentifier = "MessageAndButtonCell"
        self.action = buttonAction
        
        let labelText = NSMutableAttributedString(attributedString: Theme.detailAttributed(string: Localizations.CommandList.Search.NothingFound.For(searchTerm))!)
        let range = NSString(string: labelText.string).range(of: Localizations.CommandList.Search.NothingFound.ForHighlight)
        if range.location != NSNotFound {
            labelText.setAttributes(Theme.bodyAttributes(), range: range)
        }
        
        self.labelText = labelText
        self.buttonText = Localizations.CommandList.Search.NothingFound.ContributeContent
    }
    
    func performAction() {
        // no-op
    }
    
    func performButtonAction() {
        self.action()
    }
}
