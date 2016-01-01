//
//  ErrorCell.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class ErrorCell: UITableViewCell, BaseCell {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private var viewModel: ErrorCellViewModel!
    
    func configure(cellViewModel: BaseCellViewModel!) {
        if let vm = cellViewModel as? ErrorCellViewModel {
            self.viewModel = vm
            
            if let errorLabel = self.errorLabel {
                errorLabel.attributedText = vm.errorText
            }
            
            if let button = self.button {
                button.setTitle(vm.buttonText, forState: .Normal)
            }
        }
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        self.viewModel.performButtonAction()
    }
}
