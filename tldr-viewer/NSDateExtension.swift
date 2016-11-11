//
//  NSDateExtension.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 24/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

extension Date {
    static func timeIntervalForDays(_ days: Int) -> TimeInterval {
        return TimeInterval(days * 60 * 60 * 24)
    }
    
    static func daysForTimeInterval(_ timeInterval: TimeInterval) -> Int {
        return Int(timeInterval / (60 * 60 * 24))
    }
}
