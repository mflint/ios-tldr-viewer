//
//  InfoViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 02/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: InfoViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        self.viewModel = InfoViewModel()
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension InfoViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        
        return viewModel.groupViewModels.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        
        return viewModel.groupViewModels[section].cellViewModels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = self.viewModel!.groupViewModels[indexPath.section].cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.cellIdentifier, forIndexPath: indexPath)
        if let baseCell = cell as? BaseCell {
            baseCell.configure(cellViewModel)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel!.groupViewModels[section].groupTitle
    }
}
