//
//  DetailViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

class DetailViewModel {
    // no-op closures until the ViewController provides its own
    var updateSignal: () -> Void = {}
    
    // navigation bar title
    var navigationBarTitle: String
    
    // the message to show when there's no tldr page
    var noDataMessage: String
    
    // tldr page in HTML
    var detailHTML: String?
    
    private var command: Command!
    private var detailMarkdown: String?
    
    init(command: Command) {
        self.command = command
        self.noDataMessage = Theme.pageFromHTMLSnippet("<p>Loading...</p>")
        self.navigationBarTitle = self.command.name
        
        self.loadDetail()
        self.update()
    }
    
    func loadDetail() {
        let urlString = "https://raw.githubusercontent.com/tldr-pages/tldr/master/pages/" + self.command.platforms[0] + "/" + self.command.name + ".md"
        TLDRRequest.requestWithURL(urlString) { response in
            self.detailMarkdown = response.responseString
            self.update()
        }
    }
    
    func update() {
        if (self.detailHTML == nil) {
            if (self.detailMarkdown == nil) {
                self.detailHTML = nil
            } else {
                var markdown = Markdown()
                let html = markdown.transform(self.detailMarkdown!)
                self.detailHTML = Theme.pageFromHTMLSnippet(html)
            }
        }
        
        self.updateSignal()
    }
}