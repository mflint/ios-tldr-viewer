//
//  MessageAndButtonCell.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

protocol MessageAndButtonCellViewModel {
    var labelText: NSAttributedString! { get }
    var buttonText: String! { get }
    func performButtonAction()
}

class MessageAndButtonCell: UITableViewCell, BaseCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private var viewModel: MessageAndButtonCellViewModel!
    
    func configure(cellViewModel: BaseCellViewModel!) {
        guard let vm = cellViewModel as? MessageAndButtonCellViewModel else {
            return
        }
        
        self.viewModel = vm
        
        if let messageLabel = self.messageLabel {
            messageLabel.attributedText = vm.labelText
        }
        
        if let button = self.button {
            button.setTitle(vm.buttonText, forState: .Normal)
        }
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        self.viewModel.performButtonAction()
    }
}
