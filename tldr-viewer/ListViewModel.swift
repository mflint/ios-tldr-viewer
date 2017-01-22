//
//  ListViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation
import UIKit

class ListViewModel: NSObject {
    // no-op closures until the ViewController provides its own
    var updateSignal: (_ indexPath: IndexPath?) -> Void = {(indexPath) in}
    var showDetail: (_ detailViewModel: DetailViewModel) -> Void = {(vm) in}
    var cancelSearchSignal: () -> Void = {}
    
    var lastUpdatedString: String!
    var searchText: String = ""
    var itemSelected: Bool = false
    var requesting: Bool = false
    var sectionViewModels = [SectionViewModel]()
    var sectionIndexes = [String]()
    
    private let dateFormatter = DateFormatter()
    private let dataSource = DataSource.sharedInstance
    private var cellViewModels = [BaseCellViewModel]()
    
    override init() {
        super.init()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
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
            let lastUpdatedDateTime = dateFormatter.string(from: lastUpdateTime)
            lastUpdatedString = "Updated \(lastUpdatedDateTime)"
        } else {
            lastUpdatedString = ""
        }
        
        var vms = [BaseCellViewModel]()
        
        let commands = dataSource.commandsWith(filter: searchText)
        
        if dataSource.requesting && commands.count == 0 {
            let cellViewModel = LoadingCellViewModel()
            vms.append(cellViewModel)
        }
        
        if let errorText = dataSource.requestError {
            let cellViewModel = ErrorCellViewModel(errorText: errorText, buttonAction: {
                self.dataSource.beginRequest()
            })
            vms.append(cellViewModel)
        } else if let oldIndexCell = OldIndexCellViewModel.create(dataSource: dataSource) {
            vms.append(oldIndexCell)
        }
        
        for command in commands {
            let cellViewModel = CommandCellViewModel(command: command, action: {
                let detailViewModel = DetailViewModel(command: command)
                self.showDetail(detailViewModel)
            })
            vms.append(cellViewModel)
        }
        
        cellViewModels = vms
        makeSectionsAndCells()
        updateSignal(nil)
    }
    
    private func makeSectionsAndCells() {
        // all sections
        var sections = [SectionViewModel]()
        
        // current section
        var currentSection: SectionViewModel?
        
        for cellViewModel in cellViewModels {
            if currentSection == nil || !currentSection!.accept(cellViewModel: cellViewModel) {
                currentSection = SectionViewModel(firstCellViewModel: cellViewModel)
                sections.append(currentSection!)
            }
        }
        
        sectionViewModels = SectionViewModel.sort(sections: sections)
        sectionIndexes = sectionViewModels.map({ section in section.title })
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        selectRow(indexPath: indexPath)
        cancelSearchSignal()
    }
    
    private func selectRow(indexPath: IndexPath) {
        itemSelected = true
        sectionViewModels[indexPath.section].cellViewModels[indexPath.row].performAction()
    }
    
    func filterTextDidChange(text: String) {
        searchText = text
        update()
    }
    
    func showCommand(commandName: String) {
        // kill any search
        searchText = ""
        cancelSearchSignal()
        
        // update the results (to show all cells)
        update()
        
        // now find the NSIndexPath for the CommandCellViewModel for this command name
        var indexPath: IndexPath?
        for (sectionIndex, sectionViewModel) in sectionViewModels.enumerated() {
            for (cellIndex, cellViewModel) in sectionViewModel.cellViewModels.enumerated() {
                if let commandCellViewModel = cellViewModel as? CommandCellViewModel {
                    if commandCellViewModel.command.name == commandName {
                        indexPath = IndexPath(row: cellIndex, section: sectionIndex)
                    }
                }
            }
        }
        
        if let indexPath = indexPath {
            selectRow(indexPath: indexPath)
            updateSignal(indexPath)
        }
    }
    
    func showDetailWhenHorizontallyCompact() -> Bool {
        return itemSelected
    }
    
    func showDetail(when portrait: Bool) -> Bool {
        return !itemSelected || !portrait
    }
}
