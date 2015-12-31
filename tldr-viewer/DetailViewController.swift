//
//  DetailViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var viewModel: DetailViewModel! {
        didSet {
            self.viewModel.updateSignal = {
                dispatch_async(dispatch_get_main_queue(), {
                    self.configureView()
                })
            }
            self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView() {
        if let viewModel = self.viewModel {
            if let label = self.detailDescriptionLabel {
                label.attributedText = viewModel.detailAttributedText
            }
        }
    }
}

