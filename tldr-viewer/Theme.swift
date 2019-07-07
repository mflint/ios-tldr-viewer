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
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Color.inverseBody.uiColor(), NSAttributedString.Key.font: UIFont.tldrBody()]
        UINavigationBar.appearance().barTintColor = Color.teal.uiColor()
        UINavigationBar.appearance().backgroundColor = Color.teal.uiColor()
        UINavigationBar.appearance().tintColor = Color.inverseBody.uiColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.tldrBody()], for: .normal)

        // set the background image for UINavigationBar, which removes the ugly black shadow
        if let backgroundImage = imageWith(color: UIColor.clear) {
            UINavigationBar.appearance().shadowImage = backgroundImage
        }

        // segmented control appearance changed a lot in iOS 13
        if #available(iOS 13.0, *) {
            SegmentedControl.appearance().selectedSegmentTintColor = Color.inverseBody.uiColor()
            SegmentedControl.appearance().backgroundColor = Color.tealHighlight.uiColor()
            SegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.inverseBody.uiColor()], for: .normal)
            SegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.teal.uiColor()], for: .selected)
            
            SegmentedControlInverse.appearance().selectedSegmentTintColor = Color.teal.uiColor()
            SegmentedControlInverse.appearance().backgroundColor = Color.inverseBody.uiColor()
            SegmentedControlInverse.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.teal.uiColor()], for: .normal)
            SegmentedControlInverse.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.inverseBody.uiColor()], for: .selected)
        } else {
            SegmentedControl.appearance().tintColor = Color.inverseBody.uiColor()
            
            SegmentedControlInverse.appearance().tintColor = Color.teal.uiColor()
        }
        
        // UISearchBar text field
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.tldrBody()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = Color.inverseBody.uiColor()
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = Color.inverseBody.uiColor() // placeholder
        UISearchBar.appearance().tintColor = .white // cursor and cancel button
    }
    
    static func imageWith(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    static func css() -> String {
        let filePath = Bundle.main.url(forResource: "style", withExtension: "css")
        do {
            let data = try Data(contentsOf: filePath!)
            let cssString = String(data: data, encoding: String.Encoding.utf8)
            return cssString!
        } catch {
            return ""
        }
    }

    static func pageFrom(htmlSnippet: String) -> String {
        let result = "<html><head><meta name=\"viewport\" content=\"initial-scale=1.0\" /><style>" + css() + "</style></head><body>" + htmlSnippet + "</body></html>"
        return result
    }
    
    static func bodyAttributed(string: String?) -> NSAttributedString? {
        guard let string = string else {
            return nil
        }
        
        return NSAttributedString(string: string, attributes: bodyAttributes())
    }
    
    static func bodyAttributes() -> [NSAttributedString.Key : Any] {
        return [NSAttributedString.Key.font:UIFont.tldrBody(), NSAttributedString.Key.foregroundColor:Color.body.uiColor()]
    }
    
    static func detailAttributed(string: String?) -> NSAttributedString? {
        guard let string = string else {
            return nil
        }
        
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font:UIFont.tldrBody(), NSAttributedString.Key.foregroundColor:Color.detail.uiColor()])
    }
}

extension UIFont {
    class func tldrBody() -> UIFont {
        return UIFont(name: "Avenir-Book", size: 16)!
    }
}

enum Color: String {
    case body = "clrBody"
    case detail = "clrDetail"
    case teal = "clrTeal"
    case tealHighlight = "clrTealHighlight"
    case actionBackground = "clrActionBackground"
    case actionForeground = "clrActionForeground"
    case inverseBody = "clrBodyInverse"
    case midBody = "clrBodyMid"
    
    func uiColor() -> UIColor {
        return UIColor(named: rawValue)!
    }
}
