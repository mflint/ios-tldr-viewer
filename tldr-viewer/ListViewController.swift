//
//  ListViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var viewModel: ListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = ListViewModel()
        
        self.viewModel.updateSignal = {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        
        self.viewModel.showDetail = {(detailViewModel) -> Void in
            // show the detail
            self.performSegueWithIdentifier("showDetail", sender: detailViewModel)
            
            // and dismiss the primary overlay VC if necessary (iPad only)
            if (self.splitViewController?.displayMode == .PrimaryOverlay){
                self.splitViewController?.preferredDisplayMode = .PrimaryHidden
                self.splitViewController?.preferredDisplayMode = .Automatic
            }         }
        
        self.splitViewController?.delegate = self.viewModel;
    }

//    override func viewWillAppear(animated: Bool) {
//        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
//        super.viewWillAppear(animated)
//    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let detailVC = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
        
        if let detailViewModel = sender as? DetailViewModel {
            detailVC.viewModel = detailViewModel
        }
        
        detailVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        detailVC.navigationItem.leftItemsSupplementBackButton = true
    }
}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewModel = self.viewModel {
            return viewModel.filteredCellViewModels.count
        }
        
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = self.viewModel.filteredCellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.cellIdentifier, forIndexPath: indexPath)
        if let baseCell = cell as? BaseCell {
            baseCell.configure(cellViewModel)
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.filterTextDidChange(searchText)
    }
}

// MARK: - UITableViewDelegate

extension ListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.didSelectRowAtIndexPath(indexPath)
        self.searchBar.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }
}
