//
//  OldIndexCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 24/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

struct OldIndexCellViewModel: BaseCellViewModel, MessageAndButtonCellViewModel {
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    var labelText: NSAttributedString!
    var buttonText: String!
    
    private let dataSource: RefreshableDataSourceType
    
    static func create(dataSource: RefreshableDataSourceType) -> OldIndexCellViewModel? {
        guard let lastUpdateTime = dataSource.lastUpdateTime() else {
            return nil
        }
        
        let age = Date().timeIntervalSince(lastUpdateTime)
        if age > Date.timeIntervalForDays(5) {
            return OldIndexCellViewModel(dataSource: dataSource, age:age)
        }
        
        return nil
    }
    
    init(dataSource: RefreshableDataSourceType, age: TimeInterval) {
        self.dataSource = dataSource
        
        let days = Date.daysForTimeInterval(age)
        let messageText = Localizations.CommandList.IndexOld.NumberOfDays(days)
        
        cellIdentifier = "MessageAndButtonCell"
        labelText = Theme.detailAttributed(string: messageText)
        buttonText = Localizations.CommandList.IndexOld.UpdateNow
    }
    
    func performAction() {
        // no-op
    }
    
    func performButtonAction() {
        dataSource.beginRequest()
    }
}
