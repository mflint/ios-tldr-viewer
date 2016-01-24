//
//  NSDateExtension.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 24/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

extension NSDate {
    static func timeIntervalForDays(days: Int) -> NSTimeInterval {
        return NSTimeInterval(days * 60 * 60 * 24)
    }
    
    static func daysForTimeInterval(timeInterval: NSTimeInterval) -> Int {
        return Int(timeInterval / (60 * 60 * 24))
    }
}