//
//  BaseCellViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

protocol BaseCellViewModel {
    var cellIdentifier: String! { get }
    var action: () -> Void { get set}
    func performAction()
}