//
//  ListViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    private var viewModel: ListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ListViewModel()
        self.viewModel.updateSignal = {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.cellViewModels.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = self.viewModel.cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.cellIdentifier, forIndexPath: indexPath)
        if let baseCell = cell as? BaseCell {
            baseCell.configure(cellViewModel)
        }
        return cell
    }
}

