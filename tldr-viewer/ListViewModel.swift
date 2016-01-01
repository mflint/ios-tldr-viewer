//
//  ListViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation
import UIKit

class ListViewModel: NSObject, UISplitViewControllerDelegate {
    // no-op closures until the ViewController provides its own
    var updateSignal: () -> Void = {}
    var showDetail: (detailViewModel: DetailViewModel) -> Void = {(vm) in}
    
    internal var searchActive: Bool = false
    internal var searchText: String = ""
    
    internal var itemSelected: Bool = false
    
    private var commands = [Command]()
    private var cellViewModels = [BaseCellViewModel]()
    internal var filteredCellViewModels = [BaseCellViewModel]()
    
    override init() {
        super.init()
        self.loadIndex()
    }
    
    func loadIndex() {
        TLDRRequest.requestWithURL("https://raw.githubusercontent.com/tldr-pages/tldr-pages.github.io/master/assets/index.json") { response in
            if let jsonDict = response.responseJSON as? Dictionary<String, Array<Dictionary<String, AnyObject>>> {
                var commands = [Command]()
                
                for commandJSON in jsonDict["commands"]! {
                    let name = commandJSON["name"] as! String
                    let platforms = commandJSON["platform"] as! Array<String>
                    let command = Command(name: name , platforms: platforms)
                    
                    commands.append(command)
                }
                
                self.commands = commands;
                
                self.updateCellViewModels()
            }
        }
    }
    
    func updateCellViewModels() {
        var vms = [BaseCellViewModel]()
        
        for command in self.commands {
            let cellViewModel = CommandCellViewModel(command: command, action: {
                let detailViewModel = DetailViewModel(command: command)
                self.showDetail(detailViewModel: detailViewModel)
            })
            vms.append(cellViewModel)
        }
        
        self.cellViewModels = vms
        self.updateFilteredCellViewModels()
        self.updateSignal()
    }
    
    func updateFilteredCellViewModels() {
        self.filteredCellViewModels = self.cellViewModels.filter{ cellViewModel in
            if !self.searchActive || self.searchText.characters.count == 0 {
                return true
            }
            
            if let commandCellViewModel = cellViewModel as? CommandCellViewModel {
                return commandCellViewModel.command.name.lowercaseString.containsString(self.searchText.lowercaseString)
            }
            
            return true
        }
    }
    
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) {
        self.itemSelected = true
        self.filteredCellViewModels[indexPath.row].performAction()
    }
    
    func filterTextDidChange(text: String, active: Bool) {
        self.searchText = text
        self.searchActive = active
        self.updateFilteredCellViewModels()
        self.updateSignal()
    }
    
    // MARK: - Split view
    
    // not called for iPhone 6+ or iPad
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return !self.itemSelected
    }
    
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return self.itemSelected && UIInterfaceOrientationIsPortrait(orientation)
    }
}
