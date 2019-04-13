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
        attributeSet.contentDescription = command.summary()
        
        if let image = UIImage(named: "AppIcon") {
            attributeSet.thumbnailData = image.pngData()
        }
        
        // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: command.name, domainIdentifier: "uk.co.greenlightapps.tldr-viewer", attributeSet: attributeSet)
        item.expirationDate = Date.distantFuture
        
        // Add the item to the on-device index.
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
