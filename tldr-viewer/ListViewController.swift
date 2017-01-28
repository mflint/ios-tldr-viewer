//
//  ListViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit
import CoreSpotlight

class ListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar? {
        didSet {
            self.searchBar?.autocapitalizationType = UITextAutocapitalizationType.none
            self.searchBar?.placeholder = "Search Commands"
        }
    }
    
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    internal var viewModel: ListViewModel! {
        didSet {
            viewModel.cancelSearchSignal = {
                self.searchBar?.resignFirstResponder()
                self.searchBar?.text = self.viewModel.searchText
            }
            
            segmentedControl.removeAllSegments()
            for name in viewModel.dataSourceNames.reversed() {
                segmentedControl.insertSegment(withTitle: name, at: 0, animated: false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewModel = ListViewModel()
        
        self.view.backgroundColor = .tldrTeal()
        self.segmentedControl.selectedSegmentIndex = viewModel.selectedDataSourceIndex
        self.splitViewController?.delegate = self
        
        doShowOrHideSearchBar()
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfoPopover" {
            // this sets the color of the popover arrow on iPad, to match the UINavigationBar color of the destination VC
            segue.destination.popoverPresentationController?.backgroundColor = UIColor.tldrTeal()
        } else if segue.identifier == "embed" {
            // the embedded UITableViewController
            if let embeddedVC = segue.destination as? ListTableViewController {
                embeddedVC.viewModel = viewModel
            }
        }
    }
    
    // MARK: event handing
    
    @IBAction func onDataSourceChanged(_ sender: UISegmentedControl) {
        viewModel.selectedDataSourceIndex = sender.selectedSegmentIndex
        showOrHideSearchBar()
    }
    
    private func showOrHideSearchBar() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.doShowOrHideSearchBar()
            }
        }
    }
    
    private func doShowOrHideSearchBar() {
        let offset = self.viewModel.canSearch ? 0 : self.searchBar?.bounds.height
        if let offset = offset {
            self.searchBarTopConstraint?.constant = -offset
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.filterTextDidChange(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: - Split view

extension ListViewController: UISplitViewControllerDelegate {
    // not called for iPhone 6+ or iPad
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return !self.viewModel.showDetailWhenHorizontallyCompact()
    }
    
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false;
    }
}
