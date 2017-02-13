//
//  TextCellRightDetail.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 02/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class TextCellRightDetail: UITableViewCell, BaseCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.textContainer.lineFragmentPadding = 0
        self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.textView.tintColor = UIColor.tldrTeal()
        
        separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
    }
    
    func configure(cellViewModel: BaseCellViewModel!) {
        if let vm = cellViewModel as? TextCellViewModel {
            self.textView.attributedText = vm.attributedText
            self.detailLabel.attributedText = vm.detailAttributedText
        }
    }
}
