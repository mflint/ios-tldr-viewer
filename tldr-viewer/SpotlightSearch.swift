//
//  SpotlightSearch.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices
import UIKit

struct SpotlightSearch {
    func addToIndex(command: Command) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        // Add metadata that supplies details about the item.
        attributeSet.title = command.name
        attributeSet.contentDescription = description(command)
        
        if let image = UIImage(named: "AppIcon") {
            attributeSet.thumbnailData = UIImagePNGRepresentation(image)
        }
        
        // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: command.name, domainIdentifier: "uk.co.greenlightapps.tldr-viewer", attributeSet: attributeSet)
        item.expirationDate = NSDate.distantFuture()
        
        // Add the item to the on-device index.
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { error in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                print("Item indexed.")
            }
        }
    }
    
    private func description(command: Command) -> String {
        let detailDataSource = DetailDataSource(command: command, platform: command.platforms[0])
        
        guard let markdown = detailDataSource.markdown else {
            return ""
        }
        
        /**
         tl;dr pages conform to a specific markdown format. We'll try to grab the stuff in the first blockquote
         
         See https://github.com/tldr-pages/tldr/blob/master/CONTRIBUTING.md#markdown-format
        **/
        var result = ""
        var stop = false
        
        let lines = markdown.componentsSeparatedByString("\n")
        
        for line in lines {
            if !stop && line.hasPrefix("> ") {
                if !result.isEmpty {
                    result += " "
                }
                
                result += line.substringFromIndex(line.startIndex.advancedBy(2))
            } else if !result.isEmpty {
                stop = true
            }
        }
        
        return result
    }
}