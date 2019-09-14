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
        UINavigationBar.appearance().barTintColor = Color.backgroundTint.uiColor()
        UINavigationBar.appearance().backgroundColor = Color.backgroundTint.uiColor()
        UINavigationBar.appearance().tintColor = Color.inverseBody.uiColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.tldrBody()], for: .normal)

        // set the background image for UINavigationBar, which removes the ugly black shadow
        if let backgroundImage = imageWith(color: UIColor.clear) {
            UINavigationBar.appearance().shadowImage = backgroundImage
        }

        // segmented control appearance changed a lot in iOS 13
        if #available(iOS 13.0, *) {
            SegmentedControl.appearance().selectedSegmentTintColor = Color.segmentSelectedBackground.uiColor()
            SegmentedControl.appearance().backgroundColor = Color.segmentUnselectedBackground.uiColor() // this displays darker than the colour in the asset catalog
            SegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.segmentUnselectedForeground.uiColor()], for: .normal)
            SegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.segmentSelectedForeground.uiColor()], for: .selected)
            
            SegmentedControlInverse.appearance().selectedSegmentTintColor = Color.segmentInverseSelectedBackground.uiColor()
            SegmentedControlInverse.appearance().backgroundColor = Color.segmentInverseUnselectedBackground.uiColor()
            SegmentedControlInverse.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.segmentInverseUnselectedForeground.uiColor()], for: .normal)
            SegmentedControlInverse.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.segmentInverseSelectedForeground.uiColor()], for: .selected)
        } else {
            SegmentedControl.appearance().tintColor = Color.segmentSelectedBackground.uiColor()
            
            SegmentedControlInverse.appearance().tintColor = Color.segmentInverseSelectedBackground.uiColor()
        }
        
        // UISearchBar text field
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.tldrBody()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = Color.inverseBody.uiColor()
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = Color.inverseBody.uiColor() // placeholder
        UISearchBar.appearance().tintColor = .white // cursor and cancel button
    }
    
    private static func imageWith(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    private static func css() -> String {
        let filePath = Bundle.main.url(forResource: "style", withExtension: "css")
        do {
            let data = try Data(contentsOf: filePath!)
            if var cssString = String(data: data, encoding: String.Encoding.utf8) {
                // replace the named (asset catalog) colours with their actual values
                let capturedGroups = cssString.capturedGroups(withRegex: "#([a-zA-Z]*)")
                for capturedGroup in capturedGroups.reversed() {
                    if let hexString = Color(rawValue: capturedGroup.substring)?.uiColor().hexString {
                        cssString.replaceSubrange(capturedGroup.range, with: hexString)
                    }
                }
                return cssString
            }
            return ""
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
        
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font:UIFont.tldrBody(), NSAttributedString.Key.foregroundColor:Color.bodyDetail.uiColor()])
    }
}

extension UIFont {
    class func tldrBody() -> UIFont {
        return UIFont(name: "Avenir-Book", size: 16)!
    }
}

extension UIColor {
    var hexString: String {
        let traitCollection = UIScreen.main.traitCollection
        let colorRef: [CGFloat]?
        if #available(iOS 13.0, *) {
            colorRef = self.resolvedColor(with: traitCollection).cgColor.components
        } else {
            colorRef = cgColor.components
        }
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }
        
        return color
    }
}

enum Color: String {
    /// a strongly tinted background (example: for navigation bars)
    case backgroundTint = "clrBackgroundTint"
    
    /// a standard completely-black or completely-white background
    /// for ViewControllers
    case background = "clrBackground"

    /// the standard background colour for TableViewControllers
    case tableBackground = "clrTableBackground"

    /// a slightly lighter background colour used for TableViewCells, so the cells stand out
    /// above the TableView background. Most noticable in a grouped TableView
    case cellBackground = "clrCellBackground"
    
    /// this is the standard colour for body text
    case body = "clrBody"
    
    /// similar to "body", but slightly less contrast compared with the background. Used
    /// for the detail label in a TableViewCell. Most noticable in dark mode, when the List
    /// ViewController shows platforms for a command (linux, macos, etc)
    case bodyDetail = "clrBodyDetail"
    
    // TODO: can this go?
    /// only used as foreground colours in SegmentedControls
    case bodyTint = "clrBodyTint"
    
    /// this is a highighted colour for body text (perhaps for a tappable URL
    /// inside a paragraph of "body" text)
    case bodyHighlight = "clrBodyHighlight"
    
    ///
    case segmentSelectedBackground = "clrSegmentSelectedBackground"
    
    ///
    case segmentSelectedForeground = "clrSegmentSelectedForeground"
    
    ///
    case segmentUnselectedBackground = "clrSegmentUnselectedBackground"
    
    ///
    case segmentUnselectedForeground = "clrSegmentUnselectedForeground"
    
    ///
    case segmentInverseSelectedBackground = "clrSegmentInverseSelectedBackground"
    
    ///
    case segmentInverseSelectedForeground = "clrSegmentInverseSelectedForeground"
    
    ///
    case segmentInverseUnselectedBackground = "clrSegmentInverseUnselectedBackground"
    
    ///
    case segmentInverseUnselectedForeground = "clrSegmentInverseUnselectedForeground"

    /// the background for an action button (example: the "Update index now" button"
    case actionBackground = "clrActionBackground"
    
    /// the foreground for an action button (example: the "Update index now" button"
    case actionForeground = "clrActionForeground"
    
    /// body colour for when text is on an inversed background (example: navigation bar
    /// or segmented control)
    case inverseBody = "clrBodyInverse"
    
    /// background colour for showing code examples in the "detail" view
    case codeBackground = "clrCodeBackground"
    
    func uiColor() -> UIColor {
        return UIColor(named: rawValue)!
    }
}
