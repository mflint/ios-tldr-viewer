//
//  FilteringDataSourceDecorator.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 03/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

/// This DataSource Decorator filters out Commands based on
/// the user's locale and preferred Platforms
class FilteringDataSourceDecorator: DataSourcing {
    private let commandNameBlackList = ["fuck"] // this is a family show
    private let underlyingDataSource: DataSourcing
    
    private var delegates = WeakCollection<DataSourceDelegate>()
    private(set) var commands = [Command]()
    
    private var preferredLanguages = Set<String>()
    
    // variants of a language, to help us fall-back to something useful
    /// So `"pt-BR"` would map to `["pt-BR", "pt"]`
    private var languageVariants = [String : Set<String>]()
    
    var isSearchable: Bool {
        return underlyingDataSource.isSearchable
    }
    
    var isRefreshable: Bool {
        return underlyingDataSource.isRefreshable
    }

    init(underlyingDataSource: DataSourcing,
         localeService: LocaleServicing = LocaleService()) {
        self.underlyingDataSource = underlyingDataSource
        underlyingDataSource.add(delegate: self)
        
        preferredLanguages = localeService.preferredLanguages.map({ (languageCode) -> String in
            languageCode.lowercased()
        }).reduce(into: Set<String>(), { (results, languageCode) in
            let languageVariants = self.languageVariants(for: languageCode)
            languageVariants.forEach { (languageVariant) in
                results.insert(languageVariant)
            }
        })
    }
    
    func add(delegate: DataSourceDelegate) {
        delegates.add(delegate)
    }
    
    private func languageVariants(for languageCode: String) -> Set<String> {
        if let knownVariants = languageVariants[languageCode] {
            return knownVariants
        }
        
        var results = Set<String>()
        results.insert(languageCode)
        
        if let hyphenIndex = languageCode.firstIndex(of: "-") {
            let firstSubtag = languageCode[..<hyphenIndex]
            results.insert(String(firstSubtag))
        }
        
        languageVariants[languageCode] = results
        
        return results
    }

    private func update() {
        commands = underlyingDataSource.commands.reduce(into: [Command](), { (results, command) in
            // filter out command blacklist
            if commandNameBlackList.contains(command.name) { return }
            
            if let filteredCommand = self.filtered(command: command) {
                results.append(filteredCommand)
            }
        })
        
        delegates.forEach { (delegate) in
            delegate.dataSourceDidUpdate(dataSource: self)
        }
    }
    
    /// changes a command to remove unnecessary platforms and localisations
    /// - Parameter command: the `Command` to change
    /// - Returns: changed `Command`, or `nil` if the command is completely filtered out. (example:
    /// if the command is only available for linux and the user has specificly chosen to ignore that platform)
    private func filtered(command: Command) -> Command? {
        let remainingVariants = filtered(commandVariants: command.variants)
        guard remainingVariants.count > 0 else { return nil }
        return Command(name: command.name,
                       variants: remainingVariants)
    }
    
    private func filtered(commandVariants: [CommandVariant]) -> [CommandVariant] {
        return commandVariants.reduce(into: [CommandVariant]()) { (results, variant) in
            let filteredLanguages = filtered(languageCodes: variant.languageCodes)
            if filteredLanguages.count > 0 {
                var newVariant = CommandVariant(commandName: variant.commandName, platform: variant.platform)
                newVariant.languageCodes = filteredLanguages
                results.append(newVariant)
            }
        }
    }
    
    private func filtered(languageCodes: [String]) -> [String] {
        return languageCodes.filter { (languageCode) -> Bool in
            let variants = languageVariants(for: languageCode)
            return preferredLanguages.intersection(variants).count > 0
        }
    }
}

extension FilteringDataSourceDecorator: DataSourceDelegate {
    func dataSourceDidUpdate(dataSource: DataSourcing) {
        update()
    }
}
