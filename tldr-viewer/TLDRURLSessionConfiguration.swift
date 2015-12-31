//
//  TLDRURLSessionConfiguration.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

extension NSURLSessionConfiguration {
    class func TLDRSessionConfiguration() -> NSURLSessionConfiguration {
        let config = defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15
        return config
    }
}