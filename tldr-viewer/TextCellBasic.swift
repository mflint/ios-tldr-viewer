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
        self.textView.textContainer.lineFragmentPadding = 0;
        self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.textView.tintColor = UIColor.tldrTeal()
    }
    
    func configure(cellViewModel: BaseCellViewModel!) {
        if let vm = cellViewModel as? TextCellViewModel {
            self.textView.attributedText = vm.attributedText
        }
    }
}