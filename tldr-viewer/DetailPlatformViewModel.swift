//
//  DetailPlatformViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

extension String {
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
                let matchedString = (self as NSString).substring(with: capturedGroupRange)
                
                let swiftRange = Range(capturedGroupRange, in: self)!
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
    var platformName: String!
    var platformIndex: Int
    
    // tldr page in HTML, with CSS
    var detailHTML: String? {
        if let unstyledDetailHTML = unstyledDetailHTML {
            return Theme.pageFrom(htmlSnippet: unstyledDetailHTML)
        }
        
        return nil
    }
    
    // raw examples in this manpage
    var examples: [String]?
    
    private let dataSource: SearchableDataSourceType
    private let command: Command
    private let platform: Platform
    private var unstyledDetailHTML: String?
    
    init(dataSource: SearchableDataSourceType, command: Command, platform: Platform, platformIndex: Int) {
        self.dataSource = dataSource
        self.command = command
        self.platform = platform
        self.platformIndex = platformIndex
        
        self.platformName = platform.displayName
        
        let detailDataSource = DetailDataSource(command: command, platform: platform)
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
        
        var markdown = Markdown()
        var html = markdown.transform(changedMarkdownAndSeeAlso.markdown)
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
            result = result.replacingCharacters(in: codeTagRanges[index].range, with: replacement)
        }
        
        return result
    }
    
    /// Searches the markdown string for mentions of other commands. If other commands are found
    /// (like `csvcut` references `cut`) then this function generates some HTML for a "see also"
    /// section, and changes the reference in the markdown to a hyperlink which opens the linked
    /// command
    private func generateSeeAlso(_ markdown: String) -> (markdown:String, seeAlsoHTML:String) {
        var seeAlsoCommands = [String:Command]()
        let codeBlocksAndRanges = markdown.capturedGroups(withRegex: "`(.*?)`")
        
        for codeBlockAndRange in codeBlocksAndRanges {
            let codeBlock = codeBlockAndRange.substring
            if codeBlock != self.command.name {
                if let command = dataSource.commandWith(name: codeBlock) {
                    seeAlsoCommands[codeBlock] = command
                }
            }
        }
        
        var seeAlsoHTML = ""
        
        // make the "see also" html
        if seeAlsoCommands.count > 0 {
            seeAlsoHTML += "<div class=\"seeAlso\">"
            seeAlsoHTML += "<h2>\(Localizations.CommandDetail.SeeAlso)</h2>"
            seeAlsoHTML += "<dl>"
            for seeAlsoCommandName in seeAlsoCommands.keys.sorted() {
                let command = seeAlsoCommands[seeAlsoCommandName]!
                let summary = command.summary()
                seeAlsoHTML += "<dt><a href=\"\(seeAlsoCommandName)\">\(seeAlsoCommandName)</a></dt><dd>\(summary)</dd>"
            }
            seeAlsoHTML += "</dl></div>"
        }
        
        // change the linked commands in the markdown from a codeblock:
        //   `cut`
        // to a hyperlink:
        //   [cut](cut)
        var changedMarkdown = markdown
        for seeAlsoCommandName in seeAlsoCommands.keys {
            changedMarkdown = changedMarkdown.replacingOccurrences(of: "`\(seeAlsoCommandName)`", with: "[\(seeAlsoCommandName)](\(seeAlsoCommandName))")
        }
        
        return (markdown:changedMarkdown, seeAlsoHTML:seeAlsoHTML)
    }
}
