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
    
    static func create() -> OldIndexCellViewModel? {
        guard let lastUpdateTime = DataSources.sharedInstance.baseDataSource.lastUpdateTime() else {
            return nil
        }
        
        let age = Date().timeIntervalSince(lastUpdateTime)
        if age > Date.timeIntervalForDays(5) {
            return OldIndexCellViewModel(age:age)
        }
        
        return nil
    }
    
    init(age: TimeInterval) {
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
        DataSources.sharedInstance.baseDataSource.refresh()
    }
}
