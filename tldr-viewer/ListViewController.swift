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
        }
    }
    
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    internal var viewModel: ListViewModel! {
        didSet {
            viewModel.cancelSearchSignal = {
                DispatchQueue.main.async {
                    self.searchBar?.resignFirstResponder()
                    self.searchBar?.text = self.viewModel.searchText
                }
            }
            
            viewModel.updateSegmentSignal = {
                DispatchQueue.main.async {
                    self.segmentedControl.selectedSegmentIndex = self.viewModel.selectedDataSourceIndex
                }
            }
            
            segmentedControl.removeAllSegments()
            for name in viewModel.dataSourceNames.reversed() {
                segmentedControl.insertSegment(withTitle: name, at: 0, animated: false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = ListViewModel()
        
        segmentedControl.selectedSegmentIndex = viewModel.selectedDataSourceIndex
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible
        
        searchBar?.placeholder = viewModel.searchPlaceholder
        
        navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		if #available(iOS 13.0, *),
		   let searchTextField = searchBar?.searchTextField {
			// set the foreground colour of the placeholder text
			// (this works more reliably than
			// UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor
			searchTextField.attributedPlaceholder = NSAttributedString(string: self.viewModel.searchPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: Color.inverseBodySlightlyTransparent.uiColor()])
			// colour of the magnifying glass icon
			searchTextField.leftView?.tintColor = Color.inverseBodySlightlyTransparent.uiColor()
		}
        
        doShowOrHideSearchBar()
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.setNavigationBarHidden(false, animated: false)
	}
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfoPopover" {
            // this sets the color of the popover arrow on iPad, to match the UINavigationBar color of the destination VC
            segue.destination.popoverPresentationController?.backgroundColor = Color.backgroundTint.uiColor()
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
        self.viewModel.filterCancel()
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
        // return false, UIKit performs the default collapsing behaviour, showing the Detail VC
        // return true, UIKit doesn't perform its default collapsing behaviour, leaving the Master VC present
        
        // so return true if no command is selected, to return to the List VC;
        // otherwise return false, to keep the Detail VC.
        return !self.viewModel.showDetailWhenHorizontallyCompact()
    }
}

extension ListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // cancel the search if we start navigating, because in iOS 13 beta bug where
        // there's an ugly grey NavigationBar briefly shown when the detail VC is popped
        searchBar?.resignFirstResponder()
    }
}
