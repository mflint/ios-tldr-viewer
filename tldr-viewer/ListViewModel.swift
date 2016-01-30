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
    var cancelSearchSignal: () -> Void = {}
    
    var lastUpdatedString: String!
    var searchText: String = ""
    var itemSelected: Bool = false
    var requesting: Bool = false
    var sectionViewModels = [SectionViewModel]()
    var sectionIndexes = [String]()
    
    private let dateFormatter = NSDateFormatter()
    private let dataSource = DataSource()
    private var cellViewModels = [BaseCellViewModel]()
    
    override init() {
        super.init()
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        dataSource.updateSignal = {
            self.update()
        }
        
        update()
    }
    
    func refreshData() {
        dataSource.beginRequest()
    }
    
    private func update() {
        requesting = dataSource.requesting
        if let lastUpdateTime = dataSource.lastUpdateTime() {
            let lastUpdatedDateTime = dateFormatter.stringFromDate(lastUpdateTime)
            lastUpdatedString = "Updated \(lastUpdatedDateTime)"
        } else {
            lastUpdatedString = ""
        }
        
        var vms = [BaseCellViewModel]()
        
        let commands = dataSource.commandsWithFilter(searchText)
        
        if dataSource.requesting && commands.count == 0 {
            let cellViewModel = LoadingCellViewModel()
            vms.append(cellViewModel)
        }
        
        if let errorText = dataSource.requestError {
            let cellViewModel = ErrorCellViewModel(errorText: errorText, buttonAction: {
                self.dataSource.beginRequest()
            })
            vms.append(cellViewModel)
        } else if let oldIndexCell = OldIndexCellViewModel.create(dataSource) {
            vms.append(oldIndexCell)
        }
        
        for command in commands {
            let cellViewModel = CommandCellViewModel(command: command, action: {
                let detailViewModel = DetailViewModel(command: command)
                self.showDetail(detailViewModel: detailViewModel)
            })
            vms.append(cellViewModel)
        }
        
        cellViewModels = vms
        makeSectionsAndCells()
        updateSignal()
    }
    
    private func makeSectionsAndCells() {
        // all sections
        var sections = [SectionViewModel]()
        
        // current section
        var currentSection: SectionViewModel?
        
        for cellViewModel in cellViewModels {
            if currentSection == nil || !currentSection!.accept(cellViewModel) {
                currentSection = SectionViewModel(firstCellViewModel: cellViewModel)
                sections.append(currentSection!)
            }
        }
        
        sectionViewModels = SectionViewModel.sort(sections)
        sectionIndexes = sectionViewModels.map({ section in section.title })
    }
    
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) {
        itemSelected = true
        sectionViewModels[indexPath.section].cellViewModels[indexPath.row].performAction()
        cancelSearchSignal()
    }
    
    func filterTextDidChange(text: String) {
        searchText = text
        update()
    }
    
    func didReceiveUserActivityToShowCommand(commandName: String) {
        print("-> \(commandName)")
    }
    
    // MARK: - Split view
    
    // not called for iPhone 6+ or iPad
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return !itemSelected
    }
    
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return itemSelected && UIInterfaceOrientationIsPortrait(orientation)
    }
}
