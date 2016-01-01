//
//  LoadingCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

struct LoadingCellViewModel: BaseCellViewModel {
    var cellIdentifier: String!
    var action: ViewModelAction = {}
    
    init() {
        self.cellIdentifier = "LoadingCell"
    }
    
    func performAction() {
        // no-op
    }
}