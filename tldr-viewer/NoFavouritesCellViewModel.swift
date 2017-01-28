//
//  NoFavouritesCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 28/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

struct NoFavouritesCellViewModel: BaseCellViewModel, MessageCellViewModel {
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    var labelText: NSAttributedString!
    
    init() {
        self.cellIdentifier = "MessageCell"
        
        let labelText = NSMutableAttributedString(attributedString: Theme.detailAttributed(string: "No favourites yet!\n\nTap the ♡ button to favourite a command.")!)
        
        self.labelText = labelText
    }
    
    func performAction() {
        // no-op
    }
}
