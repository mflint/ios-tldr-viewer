//
//  LocaleService.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

protocol LocaleServicing {
    var preferredLanguages: [String] { get }
}

struct LocaleService: LocaleServicing {
    var preferredLanguages: [String] {
        var preferred = Locale.preferredLanguages
        if !preferred.contains("en") {
            preferred.append("en")
        }
        
        return preferred
    }
}
