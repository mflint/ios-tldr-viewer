//
//  ListViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation
import UIKit

/*
 
    The list of commands is loaded by the `DataSource` class, and passes through
    a series of decorators before arriving at the ListViewModel:
    
                                  +------------+
                                  | DataSource |
                                  +------+-----+
                                         |
                         +---------------+--------------+
                         | FilteringDataSourceDecorator |
                         +---------------+--------------+
                                         |
     +-----------------------------------+-----------------------------------+
     |                    SwitchingDataSourceDecorator                       |
     |                                                                       |
     |  +------------------------------+   +------------------------------+  |
     |  | SearchingDataSourceDecorator |   | FavouriteDataSourceDecorator |  |
     |  +------------------------------+   +------------------------------+  |
     +-----------------------------------+-----------------------------------+
                                         |
                                 +-------+-------+
                                 | ListViewModel |
                                 +---------------+

    `DataSource` loads the raw command data from the `Documents` directory. It
    can refresh data from the network if necessary.
 
    `FilteringDataSourceDecorator` filters the command data, removing commands
    that the user never wants to see. This might be due to their locale or their
    preferred platforms.
 
    `SwitchingDataSourceDecorator` is a type which can switch between multiple
    other decorators. Currently is has two, one for each of the segmented controls
    on the List Commands screen.
 
    `SearchableDataSourceDecorator` filters the Command list based on the user's
    search criteria.
 
    `FavouritesDataSourceDecorator` filters the Command list based on the user's
    favourite commands.
 
 */

class ListViewModel: NSObject {
    // no-op closures until the ViewController provides its own
    var updateSegmentSignal: () -> Void = {}
    var updateSignal: (_ indexPath: IndexPath?) -> Void = {(indexPath) in}
    var showDetail: (_ detailViewModel: DetailViewModel) -> Void = {(vm) in}
    var cancelSearchSignal: () -> Void = {}

    var canSearch: Bool {
        return DataSources.sharedInstance.switchingDataSource.isSearchable
    }
    
    var canRefresh: Bool {
       return DataSources.sharedInstance.switchingDataSource.isRefreshable
   }
    
    var lastUpdatedString: String {
        if let lastUpdateTime = DataSources.sharedInstance.baseDataSource.lastUpdateTime() {
            let lastUpdatedDateTime = dateFormatter.string(from: lastUpdateTime)
            return Localizations.CommandList.AllCommands.UpdatedDateTime(lastUpdatedDateTime)
        }
        
        return ""
    }
    
    var searchText: String {
        return DataSources.sharedInstance.searchingDataSource.searchText
    }
    let searchPlaceholder = Localizations.CommandList.AllCommands.SearchPlaceholder
    var itemSelected: Bool = false
    var requesting: Bool {
        return DataSources.sharedInstance.baseDataSource.requesting
    }
    
    // TODO: animate tableview contents when this changes
    // TODO: cache sectionViewModels for each selectable datasource, and only update when we get an update signal from that datasource
    var sectionViewModels = [SectionViewModel]()
    
    var sectionIndexes = [String]()
    var dataSourceNames: [String]!
    
    var detailVisible: Bool = false
    
    private let dataSource = DataSources.sharedInstance.switchingDataSource
    
    private let dateFormatter = DateFormatter()
    var selectedDataSourceIndex: Int {
        get {
            return DataSources.sharedInstance.switchingDataSource.selectedDataSourceIndex
        }
        set {
            let switcher = DataSources.sharedInstance.switchingDataSource
            switcher.selectedDataSourceIndex = newValue
            
            // update the selected datasource (segment control) in the UI
            updateSegmentSignal()
        }
    }
    
    private var cellViewModels = [BaseCellViewModel]()
    
    override init() {
        super.init()
        
        dataSource.add(delegate: self)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        dataSourceNames = DataSources.sharedInstance.switchingDataSource.underlyingDataSources.map({ (switchable) -> String in
            return switchable.name
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewModel.externalCommandChange(notification:)), name: Constant.ExternalCommandChangeNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewModel.detailShown(notification:)), name: Constant.DetailViewPresence.shownNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewModel.detailHidden(notification:)), name: Constant.DetailViewPresence.hiddenNotificationName, object: nil)
        
        DataSources.sharedInstance.baseDataSource.loadInitialCommands()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func externalCommandChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let commandName = userInfo[Constant.ExternalCommandChangeNotification.commandNameKey] as? String,
            let command = DataSources.sharedInstance.baseDataSource.commandWith(name: commandName) else {
                return
        }
        
        showCommand(commandName: command.name)
    }
    
    @objc func detailShown(notification: Notification) {
        detailVisible = true
    }
    
    @objc func detailHidden(notification: Notification) {
        detailVisible = false
    }
    
    func refreshData() {
        DataSources.sharedInstance.baseDataSource.refresh()
    }
    
    private func update() {
        var vms = [BaseCellViewModel]()
        let commands = dataSource.commands
        
        if dataSource.isRefreshable {
            if requesting {
                let cellViewModel = LoadingCellViewModel()
                vms.append(cellViewModel)
            }
            
            let baseDataSource = DataSources.sharedInstance.baseDataSource
            if let errorText = baseDataSource.requestError {
                let cellViewModel = ErrorCellViewModel(errorText: errorText, buttonAction: {
                    baseDataSource.refresh()
                })
                vms.append(cellViewModel)
            } else if !requesting, let oldIndexCell = OldIndexCellViewModel.create() {
                vms.append(oldIndexCell)
            }
        }
        
        if commands.count == 0 {
            switch dataSource.selectedDataSourceType {
            case .all:
                if !DataSources.sharedInstance.searchingDataSource.searchText.isEmpty {
                    // no search results
                    let cellViewModel = NoResultsCellViewModel(searchTerm: searchText, buttonAction: {
                        let url = URL(string: "https://github.com/tldr-pages/tldr/blob/master/CONTRIBUTING.md")!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    })
                    vms.append(cellViewModel)
                }
            case .favourites:
                vms.append(NoFavouritesCellViewModel())
            }
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
        setFilter(text: text)
    }
    
    private func setFilter(text: String) {
        DataSources.sharedInstance.searchingDataSource.searchText = text
    }
    
    func filterCancel() {
        cancelSearchSignal()
        setFilter(text: "")
    }
    
    func showCommand(commandName: String) {
        // kill any search
        cancelSearchSignal()
        DataSources.sharedInstance.searchingDataSource.searchText = ""
        
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
            if (!detailVisible) {
                // this will trigger the segue. If detail already visible, the detail viewmodel will handle it
                selectRow(indexPath: indexPath)
            }
            updateSignal(indexPath)
        }
    }
    
    func showDetailWhenHorizontallyCompact() -> Bool {
        return itemSelected
    }
}

extension ListViewModel: DataSourceDelegate {
    func dataSourceDidUpdate(dataSource: DataSourcing) {
        update()
    }
}
