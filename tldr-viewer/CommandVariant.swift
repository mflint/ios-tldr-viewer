//
//  CommandVariant.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/07/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

struct CommandVariant: Codable {
    let commandName: String
    let platform: Platform
    var languageCodes = [String]()
    
    func summary() -> String {
        let detailDataSource = DetailDataSource(self)
        
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
                
                let index = line.index(line.startIndex, offsetBy: 2)
                result += String(line[index...])
            } else if !result.isEmpty {
                stop = true
            }
        }
        
        return result
    }
}

extension CommandVariant: Comparable {
    static func < (lhs: CommandVariant, rhs: CommandVariant) -> Bool {
        return lhs.platform < rhs.platform
    }
}
