//
//  ListTableViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 23/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView.sectionIndexColor = UIColor.tldrTeal()
    }
    
    var viewModel: ListViewModel! {
        didSet {
            self.viewModel.updateSignal = {(indexPath) -> Void in
                self.update(indexPath)
            }
            
            self.viewModel.showDetail = {(detailViewModel) -> Void in
                // show the detail
                self.performSegueWithIdentifier("showDetail", sender: detailViewModel)
                
                // and dismiss the primary overlay VC if necessary (iPad only)
                if (self.splitViewController?.displayMode == .PrimaryOverlay){
                    self.splitViewController?.preferredDisplayMode = .PrimaryHidden
                    self.splitViewController?.preferredDisplayMode = .Automatic
                }
            }
            
            self.splitViewController?.delegate = self.viewModel
            
            self.update(nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // calling "beginRefreshing" / "endRefreshing" here forces the UIRefreshControl to properly layout subviews
        refreshControl?.beginRefreshing()
        refreshControl?.endRefreshing()
        
        // iPhone 6 or smaller: deselect the selected row when this ViewController reappears
        if self.splitViewController!.collapsed {
            if let selectedRow = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRowAtIndexPath(selectedRow, animated: true)
            }
        }
    }
    
    @IBAction func onPullToRefresh(sender: AnyObject) {
        viewModel.refreshData()
    }
    
    private func update(indexPath: NSIndexPath?) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            if let refreshControl = self.refreshControl {
                if self.viewModel.requesting {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
            
            self.refreshControl?.attributedTitle = NSAttributedString(string: self.viewModel.lastUpdatedString)
            
            self.tableView.reloadData()
            
            if let indexPath = indexPath {
                self.tableView.layoutIfNeeded()
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Middle)
            }
        })
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let detailVC = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            
            if let detailViewModel = sender as? DetailViewModel {
                detailVC.viewModel = detailViewModel
            }
            
            detailVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            detailVC.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

// MARK: - UITableViewDataSource

extension ListTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let viewModel = self.viewModel {
            return viewModel.sectionViewModels.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewModel = self.viewModel {
            return viewModel.sectionViewModels[section].cellViewModels.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.sectionViewModels[section].title
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellViewModel = self.viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.cellIdentifier, forIndexPath: indexPath)
        if let baseCell = cell as? BaseCell {
            baseCell.configure(cellViewModel)
        }
        return cell
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.viewModel.sectionIndexes
    }
}

// MARK: - UITableViewDelegate

extension ListTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.didSelectRowAtIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // don't show sections
        return 0
    }
}