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
        
        groups.append(GroupViewModel(groupTitle: Localizations.Info.About.Header, cellViewModels:[aboutCell(), versionCell(), authorCell()]))
        groups.append(GroupViewModel(groupTitle: Localizations.Info.Contact.Header, cellViewModels: [leaveReview(), bugReports(), contactCell()]))
        groups.append(GroupViewModel(groupTitle: Localizations.Info.Thanks.Header, cellViewModels: [thanks1(), thanks2(), thanks3()]))
        groups.append(GroupViewModel(groupTitle: Localizations.Info.OpenSource.Header, cellViewModels: [forkMe()]))
        
        groupViewModels = groups
    }
    
    private func aboutCell() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.About.Message, anchors: [Localizations.Info.About.LinkAnchor], urls: ["http://tldr-pages.github.io"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func versionCell() -> BaseCellViewModel {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return TextCellViewModel(text: Localizations.Info.Version.Title, detailText: Localizations.Info.Version.Detail(version))
    }
    
    private func authorCell() -> BaseCellViewModel {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: Date())
        return TextCellViewModel(text: Localizations.Info.Author.Title, detailText: Localizations.Info.Author.Detail(year))
    }
    
    private func leaveReview() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.LeaveReview.Message, anchors: [Localizations.Info.LeaveReview.LinkAnchor], urls: ["https://itunes.apple.com/gb/app/tldr-pages/id1071725095?mt=8"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func bugReports() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.BugReports.Message, anchors: [Localizations.Info.BugReports.LinkAnchor], urls: ["https://github.com/mflint/ios-tldr-viewer/issues"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func contactCell() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.Contact.Message, anchors: [Localizations.Info.Contact.Email.LinkAnchor, Localizations.Info.Contact.Twitter.LinkAnchor], urls: [NSURL(string: "mailto:tldr@greenlightapps.co.uk")!, "https://twitter.com/intent/tweet?text=@mkflint%20"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks1() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.Thanks._1.Message, anchors: [Localizations.Info.Thanks._1.LinkAnchor], urls: ["https://github.com/tldr-pages/tldr"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks2() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.Thanks._2.Message, anchors: [Localizations.Info.Thanks._2.LinkAnchor], urls: ["https://github.com/kristopherjohnson/Markingbird"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func thanks3() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.Thanks._3.Message, anchors: [Localizations.Info.Thanks._3.LinkAnchor.Deviantart, Localizations.Info.Thanks._3.LinkAnchor.Redbubble], urls: ["http://arabidopsis.deviantart.com/art/Teal-Deer-II-158802763", "http://www.redbubble.com/people/arabidopsis/works/5386340-1-teal-deer-too-long-didnt-read"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func forkMe() -> BaseCellViewModel {
        let message = attributedString(text: Localizations.Info.OpenSource.Message, anchors: [Localizations.Info.OpenSource.LinkAnchor], urls: ["https://github.com/mflint/ios-tldr-viewer"])
        return TextCellViewModel(attributedText: message)
    }
    
    private func attributedString(text: String, anchors: [String], urls: [Any]) -> NSAttributedString {
        let message = NSMutableAttributedString(attributedString: Theme.bodyAttributed(string: text)!)
        for (index, anchor) in anchors.enumerated() {
            let range = (text as NSString).range(of: anchor)
            message.addAttribute(NSAttributedStringKey.link, value: urls[index], range: range)
        }
        return message
    }
}
