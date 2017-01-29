//
//  Command.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

struct Command {
    let name: String!
    let platforms: [Platform]!
    
    static func sort(commands: [Command]) -> [Command] {
        return commands.sorted(by: { (first, second) -> Bool in
            return first.name.compare(second.name) == ComparisonResult.orderedAscending
        })
    }
    
    func summary() -> String {
        let detailDataSource = DetailDataSource(command: self, platform: platforms[0])
        
        guard let markdown = detailDataSource.markdown else {
            return ""
        }
        
        /**
         tl;dr pages conform to a specific markdown format. We'll try to grab the stuff in the first blockquote
         
         See https://github.com/tldr-pages/tldr/blob/master/CONTRIBUTING.md#markdown-format
         **/
        var result = ""
        var stop = false
        
        let lines = markdown.components(separatedBy: "\n")
        
        for line in lines {
            if !stop && line.hasPrefix("> ") {
                if !result.isEmpty {
                    result += " "
                }
                
                let index = line.characters.index(line.startIndex, offsetBy: 2)
                result += line.substring(from:index)
            } else if !result.isEmpty {
                stop = true
            }
        }
        
        return result
    }
}
