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

class DetailPlatformViewModel {
    // the message to show when there's no tldr page
    var message: NSAttributedString?
    
    // platform name and index
    var platformName: String
    
    // tldr page in HTML, with CSS
    var detailHTML: String? {
        if let unstyledDetailHTML = unstyledDetailHTML {
            return Theme.pageFrom(htmlSnippet: unstyledDetailHTML)
        }
        
        return nil
    }
    
    // raw examples in this manpage
    var examples: [String]?
    
    private let commandVariant: CommandVariant
    private var unstyledDetailHTML: String?
    
    init(commandVariant: CommandVariant) {
        self.commandVariant = commandVariant

        self.platformName = commandVariant.platform.displayName
        
        let detailDataSource = DetailDataSource(commandVariant)
        guard let markdown = detailDataSource.markdown else {
            handleError(detailDataSource.errorString)
            return
        }
        
        handleSuccess(markdown)
    }
    
    func example(at index: Int) -> String? {
        guard let examples = self.examples,
            index < examples.count else { return nil }
        
        return examples[index]
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
			.replacingOccurrences(of: "}}}", with: "}</span>")
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
            if seeAlsoCommands.contains(where: { $0.name == codeBlock }) {
                // Command has already been collected
                continue
            }
            
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
                    let summary = seeAlsoCommandVariant.summary()
                    let htmlSummary = (try? Down(markdownString: summary).toHTML()) ?? summary
                    seeAlsoHTML += "<dt><a href=\"\(seeAlsoCommandName)\">\(seeAlsoCommandName)</a></dt><dd>\(htmlSummary)</dd>"
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
