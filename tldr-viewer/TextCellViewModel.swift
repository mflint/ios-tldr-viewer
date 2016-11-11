//
//  TextCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 02/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

class TextCellViewModel: BaseCellViewModel {
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    var attributedText: NSAttributedString?
    var detailAttributedText: NSAttributedString?
    
    init(attributedText: NSAttributedString?, detailAttributedText: NSAttributedString?) {
        self.attributedText = attributedText
        self.detailAttributedText = detailAttributedText
        
        if detailAttributedText == nil  {
            self.cellIdentifier = "TextCellBasic"
        } else {
            self.cellIdentifier = "TextCellRightDetail"
        }
    }
    
    convenience init(text: String?, detailText: String?) {
        self.init(attributedText: Theme.bodyAttributed(string: text), detailAttributedText: Theme.detailAttributed(string: detailText))
    }

    convenience init(attributedText: NSAttributedString?) {
        self.init(attributedText: attributedText, detailAttributedText: nil)
    }
    
    convenience init(text: String?) {
        self.init(attributedText: Theme.bodyAttributed(string: text))
    }
    
    func performAction() {
        // no-op
    }
}
