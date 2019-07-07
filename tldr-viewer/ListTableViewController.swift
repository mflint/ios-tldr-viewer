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
        
        self.tableView.sectionIndexColor = Color.teal.uiColor()
    }
    
    var viewModel: ListViewModel! {
        didSet {
            self.viewModel.updateSignal = {(indexPath) -> Void in
                self.update(indexPath: indexPath)
            }
            
            self.viewModel.showDetail = {(detailViewModel) -> Void in
                // show the detail
                self.performSegue(withIdentifier: "showDetail", sender: detailViewModel)
                
                // and dismiss the primary overlay VC if necessary (iPad only)
                if (self.splitViewController?.displayMode == .primaryOverlay){
                    self.splitViewController?.preferredDisplayMode = .primaryHidden
                    self.splitViewController?.preferredDisplayMode = .automatic
                }
            }
            
            self.update(indexPath: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // calling "beginRefreshing" / "endRefreshing" here forces the UIRefreshControl to properly layout subviews
        refreshControl?.beginRefreshing()
        refreshControl?.endRefreshing()
        
        // iPhone 6 or smaller: deselect the selected row when this ViewController reappears
        if self.splitViewController!.isCollapsed {
            if let selectedRow = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedRow, animated: true)
            }
        }
    }
    
    @IBAction func onPullToRefresh(_ sender: AnyObject) {
        viewModel.refreshData()
    }
    
    private func update(indexPath: IndexPath?) -> Void {
        DispatchQueue.main.async {
            if let refreshControl = self.refreshControl {
                if self.viewModel.requesting {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
            }
            
            if self.viewModel.canRefresh {
                let refreshControl = UIRefreshControl()
                refreshControl.attributedTitle = NSAttributedString(string: self.viewModel.lastUpdatedString)
                refreshControl.addTarget(self, action: #selector(ListTableViewController.onPullToRefresh(_:)), for: .valueChanged)
                self.tableView.refreshControl = refreshControl
            } else {
                self.tableView.refreshControl = nil
            }
            
            self.tableView.reloadData()
            
            if let indexPath = indexPath {
                self.tableView.layoutIfNeeded()
                self.tableView.selectRow(at: indexPath as IndexPath, animated: true, scrollPosition: .middle)
            }
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            
            if let detailViewModel = sender as? DetailViewModel {
                detailVC.viewModel = detailViewModel
            }
            
            detailVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            detailVC.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}

// MARK: - UITableViewDataSource

extension ListTableViewController {
    override func numberOfSections(in: UITableView) -> Int {
        if let viewModel = self.viewModel {
            return viewModel.sectionViewModels.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewModel = self.viewModel {
            return viewModel.sectionViewModels[section].cellViewModels.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.sectionViewModels[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = self.viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier, for: indexPath)
        if let baseCell = cell as? BaseCell {
            baseCell.configure(cellViewModel: cellViewModel)
        }
        return cell
    }
    
    override func sectionIndexTitles(for: UITableView) -> [String]? {
        return self.viewModel.sectionIndexes
    }
}

// MARK: - UITableViewDelegate

extension ListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelectRow(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // don't show sections
        return 0
    }
}
