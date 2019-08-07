//
//  tldr_pages_tests.swift
//  tldr-pages-tests
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import XCTest
@testable import tldr_viewer

private struct CommandsAssertion {
    private let commands: [Command]
    
    init(_ commands: [Command]) {
        self.commands = commands
    }
    
    @discardableResult
    func has(count: Int,
             file: StaticString = #file,
             line: UInt = #line) -> CommandsAssertion {
        XCTAssertEqual(commands.count, count, "command count", file: file, line: line)
        return self
    }
    
    @discardableResult
    func command(named name: String,
                 file: StaticString = #file,
                 line: UInt = #line) -> CommandAssertion? {
        let commandsWithName = commands.filter { (command) -> Bool in
            command.name == name
        }
        
        guard commandsWithName.count == 1,
            let commandWithName = commandsWithName.first else {
                XCTFail("no command with name '\(name)'", file: file, line: line)
                return nil
        }
        
        return CommandAssertion(commandWithName, self)
    }
}

private struct CommandAssertion {
    private let command: Command
    private let commandsAssertion: CommandsAssertion
    
    var and: CommandsAssertion {
        get {
            commandsAssertion
        }
    }
    
    init(_ command: Command, _ commandsAssertion: CommandsAssertion) {
        self.command = command
        self.commandsAssertion = commandsAssertion
    }
    
    @discardableResult
    func with(variantCount: Int,
              file: StaticString = #file,
              line: UInt = #line) -> CommandAssertion {
        XCTAssertEqual(command.variants.count, variantCount, "variant count", file: file, line: line)
        return self
    }
    
    @discardableResult
    func has(platform expectedPlatform: TestPlatform,
             withLanguages expectedLanguages: String...,
             file: StaticString = #file,
             line: UInt = #line) -> CommandAssertion? {
        let matchingVariants = command.variants.filter { (variant) -> Bool in
            return variant.platform.name == expectedPlatform.rawValue
        }
        
        guard matchingVariants.count == 1,
            let matchingVariant = matchingVariants.first else {
                XCTFail("no variant for platform '\(expectedPlatform.rawValue)'", file: file, line: line)
                return nil
        }
        
        // this checks the order too
        XCTAssertEqual(expectedLanguages, matchingVariant.languageCodes, "language codes", file: file, line: line)
        
        return self
    }
}

class LanguageFilterTests: XCTestCase {
    private func makeFilter(_ dataSource: FakeDataSource,
                            _ localeService: LocaleServicing) -> FilteringDataSourceDecorator {
        let filter = FilteringDataSourceDecorator(underlyingDataSource: dataSource,
                                            localeService: localeService)
        dataSource.triggerUpdate()
        return filter
    }
    
    private func assert(_ commands: [Command]) -> CommandsAssertion {
        return CommandsAssertion(commands)
    }
    
    func testCommandNotChanged() {
        let command = Command(name: "test").with(platform: .linux, languages: "en")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("en")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "en")
    }
    
    func testCommandNotChanged_preferredLanguagesUpperCase() {
        let command = Command(name: "test").with(platform: .linux, languages: "en")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("EN")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "en")
    }
    
    func testCommandLanguage_zh_filteredOut() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("en")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result).has(count: 0)
    }
    
    func testCommandLanguage_zh_preferred_en_zh() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("en", "zh")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh")
    }
    
    func testCommandLanguage_en_zh_preferred_zh() {
        let command = Command(name: "test").with(platform: .linux, languages: "en", "zh")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("zh")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh")
    }
    
    func testCommandLanguage_zh_en_preferred_en_zh() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh", "en")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("en", "zh")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh", "en")
    }
    
    func testCommandLanguage_zh_Hant_en_preferred_en_zh() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh-Hant", "en")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("en", "zh")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh-Hant", "en")
    }
    
    func testCommandLanguage_zh_en_preferred_en_zh_Hant() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh", "en")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("en", "zh-Hant")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh", "en")
    }
    
    // TODO
    /*
    func testCommandLanguage_zh_zh_Hant_preferred_zh() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh", "zh-Hant")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("zh")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh")
    }
    */
    
    func testCommandLanguage_zh_preferred_zh_zh_Hant() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("zh", "zh-Hant")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh")
    }
    
    // TODO
    /*
    func testCommandLanguage_zh_zh_Hant_preferred_zh_zh_Hant() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh", "zh-Hant")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("zh", "zh-Hant")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh-Hant")
    }
    */
    
    func testCommandLanguage_zh_yue_zh_Hant_preferred_zh_yue_zh_Hant() {
        let command = Command(name: "test").with(platform: .linux, languages: "zh-yue", "zh-Hant")
        let fakeDataSource = FakeDataSource(command)
        let fakeLocale = FakeLocaleService("zh-yue", "zh-Hant")
        let filter = makeFilter(fakeDataSource, fakeLocale)
        
        let result = filter.commands
        
        assert(result)
            .has(count: 1)
            .command(named: "test")?
            .with(variantCount: 1)
            .has(platform: .linux, withLanguages: "zh-yue", "zh-Hant")
    }
}
