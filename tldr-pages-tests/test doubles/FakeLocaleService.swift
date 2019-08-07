//
//  FakeLocaleService.swift
//  tldr-pages-tests
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation
@testable import tldr_viewer

struct FakeLocaleService: LocaleServicing {
    var preferredLanguages: [String]
    
    init(_ preferredLanguages: String...) {
        self.preferredLanguages = preferredLanguages
    }
}
