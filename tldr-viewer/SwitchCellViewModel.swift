//
//  SwitchCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 12/02/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

class SwitchCellViewModel: BaseCellViewModel {
    var cellIdentifier: String! = "SwitchCell"
    var action: ViewModelAction = {}
    
    var attributedText: NSAttributedString?
    
    init(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }
    
    func performAction() {
        // no-op
    }
}
