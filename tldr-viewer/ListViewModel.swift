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
    
    internal var searchText: String = ""
    
    internal var itemSelected: Bool = false
    
    private var commands = [Command]()
    private var cellViewModels = [BaseCellViewModel]()
    private var errorState = false
    private var loading = false
    
    internal var sectionViewModels = [SectionViewModel]()
    internal var sectionIndexes = [String]()
    
    override init() {
        super.init()
        self.loadIndex()
    }
    
    private func loadIndex() {
        self.loading = true
        
        TLDRRequest.requestWithURL("https://raw.githubusercontent.com/tldr-pages/tldr-pages.github.io/master/assets/index.json") { response in
            self.processResponse(response)
        }
        
        self.updateCellViewModels()
    }
    
    private func processResponse(response: TLDRResponse) {
        self.loading = false
        
        if let error = response.error {
            self.handleError(error)
        } else if let jsonDict = response.responseJSON as? Dictionary<String, Array<Dictionary<String, AnyObject>>> {
            self.handleSuccess(jsonDict)
        }
    }
    
    private func handleError(error: NSError) {
        self.commands = []
        self.errorState = true
        
        self.updateCellViewModels()
    }
    
    private func handleSuccess(jsonDict: Dictionary<String, Array<Dictionary<String, AnyObject>>>) {
        var commands = [Command]()
        
        for commandJSON in jsonDict["commands"]! {
            let name = commandJSON["name"] as! String
            var platforms = [Platform]()
            for platformName in commandJSON["platform"] as! Array<String> {
                let platform = Platform.get(platformName)
                platforms.append(platform)
            }
            let command = Command(name: name , platforms: Platform.sort(platforms))
            
            commands.append(command)
        }
        
        self.commands = Command.sort(commands)
        self.errorState = false
        
        self.updateCellViewModels()
    }
    
    private func updateCellViewModels() {
        var vms = [BaseCellViewModel]()
        
        if (self.loading) {
            let cellViewModel = LoadingCellViewModel()
            vms.append(cellViewModel)
        } else {
            if (self.errorState) {
                let cellViewModel = ErrorCellViewModel(buttonAction: {
                    self.loadIndex()
                })
                vms.append(cellViewModel)
            }
            
            for command in self.commands {
                let cellViewModel = CommandCellViewModel(command: command, action: {
                    let detailViewModel = DetailViewModel(command: command)
                    self.showDetail(detailViewModel: detailViewModel)
                })
                vms.append(cellViewModel)
            }
        }
        
        self.cellViewModels = vms
        self.makeFilteredSectionsAndCells()
        self.updateSignal()
    }
    
    private func makeFilteredSectionsAndCells() {
        let filteredCellViewModels = self.cellViewModels.filter{ cellViewModel in
            // if the search string is empty, return everything
            if self.searchText.characters.count == 0 {
                return true
            }
            
            // otherwise 
            if let commandCellViewModel = cellViewModel as? CommandCellViewModel {
                return commandCellViewModel.command.name.lowercaseString.containsString(self.searchText.lowercaseString)
            }
            
            return true
        }
        
        // all sections
        var sections = [SectionViewModel]()
        
        // current section
        var currentSection: SectionViewModel?
        
        for cellViewModel in filteredCellViewModels {
            if currentSection == nil || !currentSection!.accept(cellViewModel) {
                currentSection = SectionViewModel(firstCellViewModel: cellViewModel)
                sections.append(currentSection!)
            }
        }
        
        self.sectionViewModels = SectionViewModel.sort(sections)
        self.sectionIndexes = self.sectionViewModels.map({ section in section.title })
    }
    
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) {
        self.itemSelected = true
        self.sectionViewModels[indexPath.section].cellViewModels[indexPath.row].performAction()
    }
    
    func filterTextDidChange(text: String) {
        self.searchText = text
        self.makeFilteredSectionsAndCells()
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
