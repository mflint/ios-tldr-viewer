//
//  DetailDataSource.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 23/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

struct DetailDataSource {
    let markdown: String?
    let errorString: String?
    
    init(command: Command, platform: Platform) {
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        let fileURL = documentsDirectory
            .URLByAppendingPathComponent("pages")
            .URLByAppendingPathComponent(platform.name)
            .URLByAppendingPathComponent(command.name)
            .URLByAppendingPathExtension("md")
        
        do {
            let content = try String(contentsOfURL:fileURL, encoding: NSUTF8StringEncoding)
            markdown = content
            errorString = nil
        } catch {
            markdown = nil
            errorString = "Could not find tl;dr"
        }
    }
}