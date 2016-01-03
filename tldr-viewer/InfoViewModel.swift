//
//  InfoViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 02/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class InfoViewModel {
    var groupViewModels = [GroupViewModel]()
    
    init() {
        self.updateCellViewModels()
    }
    
    private func updateCellViewModels() {
        var groups = [GroupViewModel]()
        
        groups.append(GroupViewModel(groupTitle: "About", cellViewModels:[self.aboutCell(), self.versionCell()]))
        groups.append(GroupViewModel(groupTitle: "Contact", cellViewModels: [self.contactCell()]))
        groups.append(GroupViewModel(groupTitle: "Thanks to", cellViewModels: [self.thanks1(), self.thanks2(), self.thanks3()]))
        groups.append(GroupViewModel(groupTitle: "Open Source app", cellViewModels: [self.forkMe()]))
        
        self.groupViewModels = groups
    }
    
    private func aboutCell() -> BaseCellViewModel {
        let message = self.attributedString("An iOS client for tldr-pages - simplified and community-driven man pages.", anchors: ["tldr-pages"], urls: ["http://tldr-pages.github.io"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func versionCell() -> BaseCellViewModel {
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        return TextCellViewModel(text: "Version", detailText: version)
    }
    
    private func contactCell() -> BaseCellViewModel {
        let message = self.attributedString("Contact via email or Twitter.", anchors: ["email", "Twitter"], urls: [NSURL(string: "mailto:tldr@greenlightapps.co.uk")!, "https://twitter.com/mkflint"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks1() -> BaseCellViewModel {
        let message = self.attributedString("Romain Prieto and all other contributors to TLDR-pages.", anchors: ["TLDR-pages"], urls: ["https://github.com/tldr-pages/tldr"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks2() -> BaseCellViewModel {
        let message = self.attributedString("Kristopher Johnson for Markingbird, a Markdown processor in Swift.", anchors: ["Markingbird"], urls: ["https://github.com/kristopherjohnson/Markingbird"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks3() -> BaseCellViewModel {
        let message = self.attributedString("'Arabidopsis' for the gorgeous teal-deer artwork, found on DeviantArt. It's available on a shirt via Redbubble. (All profits go to the artist)", anchors: ["DeviantArt", "Redbubble"], urls: ["http://arabidopsis.deviantart.com/art/Teal-Deer-II-158802763", "http://www.redbubble.com/people/arabidopsis/works/5386340-1-teal-deer-too-long-didnt-read"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func forkMe() -> BaseCellViewModel {
        let message = self.attributedString("Fork me on GitHub!", anchors: ["GitHub"], urls: ["https://github.com/mflint/ios-tldr-viewer"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func attributedString(text: String, anchors: [String], urls: [AnyObject]) -> NSAttributedString {
        let message = NSMutableAttributedString(attributedString: Theme.bodyAttributed(text)!)
        for (index, anchor) in anchors.enumerate() {
            let range = (text as NSString).rangeOfString(anchor)
            message.addAttribute(NSLinkAttributeName, value: urls[index], range: range)
        }
        return message
    }
}