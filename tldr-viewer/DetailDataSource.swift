//
//  DetailDataSource.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 23/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

/// `DetailDataSource` can get markdown content for a `CommandVariant`
struct DetailDataSource {
    let markdown: String?
    let errorString: String?
    
    /// Returns a collection of `DetailDataSource` objects, one for each `languageCode` supported
    /// by the given `commandVariant`.
    /// - Parameter commandVariant: the command variant
    static func dataSources(for commandVariant: CommandVariant) -> [String: DetailDataSource] {
        return commandVariant.languageCodes.reduce(into: [String: DetailDataSource]()) { (results, languageCode) in
            results[languageCode] = DetailDataSource(commandVariant, languageCode)
        }
    }
    
    private init(_ commandVariant: CommandVariant, _ languageCode: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // the pages folder for English is `pages`. For other language codes, it is
        // `pages.{languageCode}`
        let pagesDirectory = languageCode == "en" ? "pages" : "pages.\(languageCode)"
        
        let fileURL = documentsDirectory
            .appendingPathComponent(pagesDirectory)
            .appendingPathComponent(commandVariant.platform.name)
            .appendingPathComponent(commandVariant.commandName)
            .appendingPathExtension("md")
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            markdown = content
            errorString = nil
        } catch {
            markdown = nil
            errorString = Localizations.CommandDetail.Error.CouldNotFindTldr
        }
    }
}
