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
            self.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        }
    }
    
    private var viewModel: ListViewModel! {
        didSet {
            self.viewModel.cancelSearchSignal = {
                self.searchBar.resignFirstResponder()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewModel = ListViewModel()
    }

    // MARK: - NSUserActivity stuff
    override func restoreUserActivityState(activity: NSUserActivity) {
        if let uniqueIdentifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.didReceiveUserActivityToShowCommand(uniqueIdentifier)
        }
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showInfoPopover" {
            // this sets the color of the popover arrow on iPad, to match the UINavigationBar color of the destination VC
            segue.destinationViewController.popoverPresentationController?.backgroundColor = UIColor.tldrTeal()
        } else if segue.identifier == "embed" {
            // the embedded UITableViewController
            if let embeddedVC = segue.destinationViewController as? ListTableViewController {
                embeddedVC.viewModel = viewModel
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.filterTextDidChange(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
