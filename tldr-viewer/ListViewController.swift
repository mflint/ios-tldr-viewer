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
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        }
    }
    
    internal var viewModel: ListViewModel! {
        didSet {
            self.viewModel.cancelSearchSignal = {
                self.searchBar.resignFirstResponder()
                self.searchBar.text = self.viewModel.searchText
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewModel = ListViewModel()
        
        self.splitViewController?.delegate = self
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
}

// MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.filterTextDidChange(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Split view

extension ListViewController: UISplitViewControllerDelegate {
    // not called for iPhone 6+ or iPad
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return !self.viewModel.showDetailWhenHorizontallyCompact()
    }
    
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return self.viewModel.showDetail(when: UIInterfaceOrientationIsPortrait(orientation))
    }
}
