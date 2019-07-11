//
//  TextCellBasic.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 03/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class TextCellBasic: UITableViewCell, BaseCell {
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.textContainer.lineFragmentPadding = 0
        self.textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // textView.tintColor sets the colour for the NSAttributedString.Key.link
        // parts of any attributed strings
        self.textView.tintColor = Color.bodyHighlight.uiColor()
    }
    
    func configure(cellViewModel: BaseCellViewModel!) {
        if let vm = cellViewModel as? TextCellViewModel {
            self.textView.attributedText = vm.attributedText
        }
    }
}
