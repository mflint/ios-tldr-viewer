//
//  GroupViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 02/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

struct GroupViewModel {
    let title: String
    let cellViewModels: [BaseCellViewModel]
    let footer: String?
}
