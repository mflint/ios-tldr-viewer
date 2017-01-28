//
//  RefreshableDataSourceType.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation

protocol RefreshableDataSourceType {
    func beginRequest()
    var requesting: Bool { get set }
    func lastUpdateTime() -> Date?
    var requestError: String? { get }
}
