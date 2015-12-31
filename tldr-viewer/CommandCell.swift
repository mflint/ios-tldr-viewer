//
//  CommandCell.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit

class CommandCell: UITableViewCell, BaseCell {
    func configure(cellViewModel: BaseCellViewModel!) {
        if let vm = cellViewModel as? CommandCellViewModel {
            self.textLabel?.text = vm.commandText
            self.detailTextLabel?.text = vm.platforms
        }
    }
}