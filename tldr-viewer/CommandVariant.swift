//
//  CommandVariant.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 27/07/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

/// `CommandVariant` represents a `Command` for a single `Platform`. eg. `head` for `osx`.
/// This value will have at least one `languageCode`, possibly more.
struct CommandVariant: Codable {
    let commandName: String
    let platform: Platform
    
    // TODO: change this type to `Set<String>` so we can't rely on any natural ordering of language codes
    /// collection of language codes available for this `CommandVariant`
    var languageCodes = [String]()
    
    /// returns a command summary in the given preferred language code; if there is
    /// no summaru available for that language code, then returns a summary for
    /// another of the user's preferred languages, according to `Locale`, or
    /// English as a last resort
    /// - Parameter languageCode: the preferred language code
    func summary(preferredLanguage languageCode: String) -> String {
        if let result = summary(languageCode: languageCode) {
            return result
        }
        
        return summaryInPreferredLanguage()
    }
    
    /// returns a command summary for one of the user's preferred language codes,
    /// according to `Locale` or English as a last resort
    func summaryInPreferredLanguage() -> String {
        // TODO: this should do better language-matching
        // eg. if the users preferred language is "pt-BR", then this
        // function should also match "pt"
        for otherLanguageCode in LocaleService().preferredLanguages {
            if let result = summary(languageCode: otherLanguageCode) {
                return result
            }
        }
        
        return ""
    }
    
    private func summary(languageCode: String) -> String? {
        let dataSources = DetailDataSource.dataSources(for: self)
        
        guard let detailDataSource = dataSources[languageCode],
            let markdown = detailDataSource.markdown else {
            return nil
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
