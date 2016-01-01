//
//  Theme.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    static func setup() {
        // navigation bar and item
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.tldrLightBody(), NSFontAttributeName: UIFont.tldrBody()]
        UINavigationBar.appearance().barTintColor = UIColor.tldrTeal()
        UINavigationBar.appearance().tintColor = UIColor.tldrLightBody()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.tldrBody()], forState: .Normal)
        
        // segmented control
        UISegmentedControl.appearance().tintColor = UIColor.tldrTeal()
    }
    
    static func css() -> String {
        let filePath = NSBundle.mainBundle().URLForResource("style", withExtension: "css")
        let data = NSData(contentsOfURL: filePath!)
        let cssString = String(data: data!, encoding: NSUTF8StringEncoding)
        return cssString!
    }

    static func pageFromHTMLSnippet(htmlSnippet: String) -> String {
        let result = "<html><head><style>" + css() + "</style></head><body>" + htmlSnippet + "</body></html>"
        return result
    }
    
    static func bodyAttributed(string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [NSFontAttributeName:UIFont.tldrBody(), NSForegroundColorAttributeName:UIColor.tldrBody()])
    }
    
    static func detailAttributed(string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [NSFontAttributeName:UIFont.tldrBody(), NSForegroundColorAttributeName:UIColor.tldrDetail()])
    }
}

extension UIFont {
    class func tldrBody() -> UIFont {
        return UIFont(name: "Avenir-Book", size: 16)!
    }
}

extension UIColor {
    class func tldrBody() -> UIColor {
        return UIColor.blackColor()
    }
    
    class func tldrDetail() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    class func tldrTeal() -> UIColor {
        return UIColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    class func tldrLightBody() -> UIColor {
        return UIColor.whiteColor()
    }
}
