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
        updateCellViewModels()
    }
    
    private func updateCellViewModels() {
        var groups = [GroupViewModel]()
        
        groups.append(GroupViewModel(groupTitle: "About", cellViewModels:[aboutCell(), versionCell(), authorCell()]))
        groups.append(GroupViewModel(groupTitle: "Contact", cellViewModels: [bugReports(), contactCell()]))
        groups.append(GroupViewModel(groupTitle: "Thanks to", cellViewModels: [thanks1(), thanks2(), thanks3(), thanks4()]))
        groups.append(GroupViewModel(groupTitle: "Open Source app", cellViewModels: [forkMe()]))
        
        groupViewModels = groups
    }
    
    private func aboutCell() -> BaseCellViewModel {
        let message = attributedString(text: "An iOS client for tldr-pages - simplified and community-driven man pages.", anchors: ["tldr-pages"], urls: ["http://tldr-pages.github.io"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func versionCell() -> BaseCellViewModel {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return TextCellViewModel(text: "Version", detailText: version)
    }
    
    private func authorCell() -> BaseCellViewModel {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: Date())
        return TextCellViewModel(text: "Author", detailText: "© \(year) Green Light Apps")
    }
    
    private func bugReports() -> BaseCellViewModel {
        let message = attributedString(text: "Bug reports, requests, pull requests welcome at the GitHub Issues page.", anchors: ["GitHub Issues"], urls: ["https://github.com/mflint/ios-tldr-viewer/issues"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func contactCell() -> BaseCellViewModel {
        let message = attributedString(text: "Contact via email or Twitter.", anchors: ["email", "Twitter"], urls: [NSURL(string: "mailto:tldr@greenlightapps.co.uk")!, "https://twitter.com/intent/tweet?text=@mkflint%20"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks1() -> BaseCellViewModel {
        let message = attributedString(text: "Romain Prieto and all other contributors to TLDR-pages.", anchors: ["TLDR-pages"], urls: ["https://github.com/tldr-pages/tldr"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks2() -> BaseCellViewModel {
        let message = attributedString(text: "Kristopher Johnson for Markingbird, a Markdown processor in Swift.", anchors: ["Markingbird"], urls: ["https://github.com/kristopherjohnson/Markingbird"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks3() -> BaseCellViewModel {
        let message = attributedString(text: "'Arabidopsis' for the gorgeous teal-deer artwork, found on DeviantArt. It's available on a shirt via Redbubble. (All profits go to the artist)", anchors: ["DeviantArt", "Redbubble"], urls: ["http://arabidopsis.deviantart.com/art/Teal-Deer-II-158802763", "http://www.redbubble.com/people/arabidopsis/works/5386340-1-teal-deer-too-long-didnt-read"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks4() -> BaseCellViewModel {
        let message = attributedString(text: "All our beta testers. Contact us to join the group.", anchors: ["Contact us"], urls: [NSURL(string: "mailto:tldr@greenlightapps.co.uk")!])
        return TextCellViewModel(attributedText: message)
    }
    
    private func forkMe() -> BaseCellViewModel {
        let message = attributedString(text: "Fork me on GitHub!", anchors: ["GitHub"], urls: ["https://github.com/mflint/ios-tldr-viewer"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func attributedString(text: String, anchors: [String], urls: [Any]) -> NSAttributedString {
        let message = NSMutableAttributedString(attributedString: Theme.bodyAttributed(string: text)!)
        for (index, anchor) in anchors.enumerated() {
            let range = (text as NSString).range(of: anchor)
            message.addAttribute(NSLinkAttributeName, value: urls[index], range: range)
        }
        return message
    }
}
