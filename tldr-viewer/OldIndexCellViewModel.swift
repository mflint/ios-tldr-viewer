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
    
    private let dataSource: DataSource
    
    static func create(dataSource: DataSource) -> OldIndexCellViewModel? {
        guard let lastUpdateTime = dataSource.lastUpdateTime() else {
            return nil
        }
        
        let age = NSDate().timeIntervalSinceDate(lastUpdateTime)
        if age > NSDate.timeIntervalForDays(5) {
            return OldIndexCellViewModel(dataSource: dataSource, age:age)
        }
        
        return nil
    }
    
    init(dataSource: DataSource, age: NSTimeInterval) {
        self.dataSource = dataSource
        
        let days = NSDate.daysForTimeInterval(age)
        let messageText = "The index is \(days) days old."
        
        cellIdentifier = "MessageAndButtonCell"
        labelText = Theme.detailAttributed(messageText)
        buttonText = "Update index now"
    }
    
    func performAction() {
        // no-op
    }
    
    func performButtonAction() {
        dataSource.beginRequest()
    }
}