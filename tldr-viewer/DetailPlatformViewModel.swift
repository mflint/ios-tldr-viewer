//
//  DetailPlatformViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation
import Down

extension String {
    // TODO: why don't the returned ranges play nicely with unicode strings?
    // if we iterate over the returned ranges, in reverse, ranges earlier in the string
    // (and later in the ierator) start matching unexpected substrings as the
    // string is mutated. Why do mutations toward the end of the string affect
    // substrings towards the beginning?
    func capturedGroups(withRegex pattern: String) -> [(substring: String, range: Range<String.Index>)] {
        var results = [(String, Range<String.Index>)]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        
        for match in matches {
            let lastRangeIndex = match.numberOfRanges - 1
            guard lastRangeIndex >= 1 else { return results }
            
            for i in 1...lastRangeIndex {
                let capturedGroupRange = match.range(at: i)
                let swiftRange = Range(capturedGroupRange, in: self)!
                let matchedString = String(self[swiftRange])
                
                results.append((matchedString, swiftRange))
            }
        }
        
        return results
    }
}

protocol DetailPlatformViewModelDelegate: class {
    /// something happened which requires the markdown text to be updated.
    /// perhaps the language code changed?
    func updated()
}

/// This is the ViewModel for a single CommandVariant. (That is a single Command/Platform combination)
/// If the displayed Command has three platforms, then there will be three instances of `DetailPlatformViewModel`
class DetailPlatformViewModel {
    weak var delegate: DetailPlatformViewModelDelegate?
    
    /// the message to show when there's no tldr page
    var message: NSAttributedString?
    
    /// platform name and index
    var platformName: String
    
    /// tldr page in HTML, with CSS
    var detailHTML: String? {
        if let unstyledDetailHTML = unstyledDetailHTML {
            return Theme.pageFrom(htmlSnippet: unstyledDetailHTML)
        }
        
        return nil
    }
    
    /// when there are multiple languages for this CommandVariant, this button
    /// shows the next language in the list, in that language.
    /// examples: "English", "italiano", "中文"
    var nextLanguageButtonTitle: String?
    
    /// raw examples in this manpage
    var examples: [String]?
    
    // this is the CommandVariant that this ViewModel will display
    private let commandVariant: CommandVariant
    
    // this is the result of converting Markdown to HTML; the `detailHTML`
    // computed property takes this unstyled HTML and adds some CSS.
    // We do it like this because parsing the Markdown to HTML might be expensive,
    // and this makes it easy to recalculate _styled_ HTML if we switch
    // between light mode and dark mode
    // TODO: turn this into a dictionary, keyed by languageCode
    private var unstyledDetailHTML: String?

    // multi-language support
    // if a CommandVariant supplies Markdown in more than one language,
    // then we can switch between them
    private var languageIndex = 0
    private let languageCodes: [String]
    private let detailsByLanguageCode: [String: DetailDataSource]

    init(commandVariant: CommandVariant) {
        self.commandVariant = commandVariant
        
        // TODO: this collection of language codes should be in the correct order,
        // determined by LocaleService.preferredLanguages, not the order supplied by
        // the `CommandVariant`
        self.languageCodes = commandVariant.languageCodes
        self.detailsByLanguageCode = DetailDataSource.dataSources(for: commandVariant)
        self.platformName = commandVariant.platform.displayName
        
        updateContent()
    }
    
    /// Returns the code example at the given index. Called when a user taps on a code example,
    /// so we can copy it to the pasteboard
    /// - Parameter index: the index of the code example
    /// - Returns: a String containing the code example
    func example(at index: Int) -> String? {
        guard let examples = self.examples,
            index < examples.count else { return nil }
        
        return examples[index]
    }
    
    /// Switches the display to the next language in the `CommandVariant`
    func nextLanguage() {
        languageIndex = (languageIndex + 1) % languageCodes.count
        updateContent()
        delegate?.updated()
    }
    
    private func updateContent() {
        let languageCode = languageCodes[languageIndex]
        
        if let detailDataSource = detailsByLanguageCode[languageCode] {
            if let markdown = detailDataSource.markdown {
                handleSuccess(markdown)
            } else {
                handleError(detailDataSource.errorString)
            }
        } else {
            handleError(Localizations.CommandDetail.Error.CouldNotFindTldr)
        }
        
        if languageCodes.count < 2 {
            nextLanguageButtonTitle = nil
        } else {
            let nextLanguageCode = languageCodes[(languageIndex + 1) % languageCodes.count]
            nextLanguageButtonTitle = Locale(identifier: nextLanguageCode).localizedString(forIdentifier: nextLanguageCode)
        }
    }
    
    private func handleError(_ error: String?) {
        self.message = Theme.detailAttributed(string: error)
    }
    
    private func handleSuccess(_ markdownString: String) {
        let changedMarkdownAndSeeAlso = generateSeeAlso(markdownString)
        let down = Down(markdownString: changedMarkdownAndSeeAlso.markdown)
        var html = (try? down.toHTML()) ?? Localizations.CommandDetail.Error.CouldParse
        
        html = linkifyCodeBlocks(markdown: changedMarkdownAndSeeAlso.markdown, html: html)
            .replacingOccurrences(of: "{{", with: "<span class='parameter'>")
            .replacingOccurrences(of: "}}", with: "</span>")
        
        unstyledDetailHTML = html + changedMarkdownAndSeeAlso.seeAlsoHTML
        
        self.message = nil
    }
    
    private func linkifyCodeBlocks(markdown: String, html: String) -> String {
        let examples = markdown.capturedGroups(withRegex: "`(.*?)`")
        let codeTagRanges = html.capturedGroups(withRegex: "(<code.*?/code>)")
        
        guard examples.count == codeTagRanges.count else { return html }
        
        self.examples = [String]()
        for index in (0..<examples.count) {
            let example = examples[index].substring
                .replacingOccurrences(of: "{{", with: "")
                .replacingOccurrences(of: "}}", with: "")
            self.examples?.append(example)
        }
        
        var result = html
        for index in (0..<examples.count).reversed() {
            let codeBlock = codeTagRanges[index].substring
            let replacement = "<a class='copylink' href=\"tldr://pasteboard/\(index)\">\(codeBlock)</a>"
            result = result.replacingOccurrences(of: codeTagRanges[index].substring, with: replacement)
        }
        
        return result
    }
    
    /// Searches the markdown string for mentions of other commands. If other commands are found
    /// (like `csvcut` references `cut`) then this function generates some HTML for a "see also"
    /// section, and changes the reference in the markdown to a hyperlink which opens the linked
    /// command
    private func generateSeeAlso(_ markdown: String) -> (markdown:String, seeAlsoHTML:String) {
        var seeAlsoCommands = [Command]()
        let codeBlocksAndRanges = markdown.capturedGroups(withRegex: "`(.*?)`")
        
        // this dataSource is used for finding related Commands
        let dataSource = DataSources.sharedInstance.filteredDataSource
        
        for codeBlockAndRange in codeBlocksAndRanges {
            let codeBlock = codeBlockAndRange.substring
            
            // check this codeblock doesn't reference the current command -
            // we don't want to generate hyperlinks to ourself
            if codeBlock != commandVariant.commandName {
                let matchingCommands = dataSource.commands.filter { (command) -> Bool in
                    command.name == codeBlock
                }
                if let matchingCommand = matchingCommands.first {
                    seeAlsoCommands.append(matchingCommand)
                }
            }
        }
        
        var seeAlsoHTML = ""
        
        // make the "see also" html
        if seeAlsoCommands.count > 0 {
            seeAlsoCommands.sort()
            
            seeAlsoHTML += "<div class=\"seeAlso\">"
            seeAlsoHTML += "<h2>\(Localizations.CommandDetail.SeeAlso)</h2>"
            seeAlsoHTML += "<dl>"
            
            for seeAlsoCommand in seeAlsoCommands {
                let seeAlsoCommandName = seeAlsoCommand.name
                
                // if there's a platform variant for this command which is the same
                // as out currently-selected platform, then use that for the summary
                var seeAlsoCommandVariant = seeAlsoCommand.variants.filter { (variant) -> Bool in
                    variant.platform == self.commandVariant.platform
                }.first
                
                // if not, then use the first variant for this seeAlsoCommand
                if seeAlsoCommandVariant == nil {
                    seeAlsoCommandVariant = seeAlsoCommand.variants.first
                }
                
                if let seeAlsoCommandVariant = seeAlsoCommandVariant {
                    let languageCode = languageCodes[languageIndex]
                    let summary = seeAlsoCommandVariant.summary(preferredLanguage: languageCode)
                    seeAlsoHTML += "<dt><a href=\"\(seeAlsoCommandName)\">\(seeAlsoCommandName)</a></dt><dd>\(summary)</dd>"
                }
            }
            seeAlsoHTML += "</dl></div>"
        }
        
        // change the linked commands in the markdown from a codeblock:
        //   `cut`
        // to a hyperlink:
        //   [cut](cut)
        var changedMarkdown = markdown
        for seeAlsoCommand in seeAlsoCommands {
            let seeAlsoCommandName = seeAlsoCommand.name
            changedMarkdown = changedMarkdown.replacingOccurrences(of: "`\(seeAlsoCommandName)`", with: "[\(seeAlsoCommandName)](\(seeAlsoCommandName))")
        }
        
        return (markdown:changedMarkdown, seeAlsoHTML:seeAlsoHTML)
    }
}
