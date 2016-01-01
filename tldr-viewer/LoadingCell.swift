//
//  LoadingCell.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell, BaseCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func configure(cellViewModel: BaseCellViewModel!) {
        self.activityIndicator.color = UIColor.tldrTeal()
        self.activityIndicator.startAnimating()
    }
}