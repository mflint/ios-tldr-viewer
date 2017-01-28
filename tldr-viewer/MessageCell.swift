//
//  MessageCell.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 28/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation
import UIKit

protocol MessageCellViewModel {
    var labelText: NSAttributedString! { get }
}

class MessageCell: UITableViewCell, BaseCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    private var viewModel: MessageCellViewModel!
    
    func configure(cellViewModel: BaseCellViewModel!) {
        guard let vm = cellViewModel as? MessageCellViewModel else {
            return
        }
        
        self.viewModel = vm
        
        if let messageLabel = self.messageLabel {
            messageLabel.attributedText = vm.labelText
        }
    }
}
