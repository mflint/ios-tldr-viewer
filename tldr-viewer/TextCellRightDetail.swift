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
        self.textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.textView.tintColor = UIColor.tldrTeal()
    }
    
    func configure(cellViewModel: BaseCellViewModel!) {
        if let vm = cellViewModel as? TextCellViewModel {
            self.textView.attributedText = vm.attributedText
            self.detailLabel.attributedText = vm.detailAttributedText
        }
    }
}
