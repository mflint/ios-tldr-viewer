//
//  SwitchCell.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 12/02/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell, BaseCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var swtch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSwitchChanged(_ sender: UISwitch) {
    }
    
    func configure(cellViewModel: BaseCellViewModel!) {
        guard let cellViewModel = cellViewModel as? SwitchCellViewModel else { return }
        
        self.label.attributedText = cellViewModel.attributedText
    }
}
