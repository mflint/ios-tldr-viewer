//
//  DetailPlatformViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

class DetailPlatformViewModel {
    // the message to show when there's no tldr page
    var message: NSAttributedString?
    var loading: Bool = false
    var buttonTitle: String?
    
    // platform name and index
    var platformName: String!
    var platformIndex: Int
    
    // tldr page in HTML
    var detailHTML: String?
    
    private var updateSignal: () -> Void
    private var command: Command!
    private var platform: Platform!
    
    init(updateSignal: () -> Void, command: Command, platform: Platform, platformIndex: Int) {
        self.updateSignal = updateSignal
        self.command = command
        self.platform = platform
        self.platformIndex = platformIndex
        
        self.platformName = platform.displayName
    }
    
    func loadDetailIfRequired() {
        if (self.detailHTML == nil) {
            self.message = Theme.detailAttributed("Loading...")
            self.buttonTitle = nil
            self.loading = true
            
            let urlString = "https://raw.githubusercontent.com/tldr-pages/tldr/master/pages/" + self.platform.name + "/" + self.command.name + ".md"
            TLDRRequest.requestWithURL(urlString) { response in
                self.processResponse(response)
            }
        }
        
        self.update()
    }
    
    private func update() {
        self.updateSignal()
    }
    
    private func processResponse(response: TLDRResponse) {
        self.loading = false
        
        if let error = response.error {
            self.handleError(error)
        } else if let markdownString = response.responseString {
            self.handleSuccess(markdownString)
        }
        
        self.update()
    }
    
    private func handleError(error: NSError) {
        self.message = Theme.detailAttributed("Could not fetch the tldr-page")
        self.buttonTitle = "Try again"
    }
    
    private func handleSuccess(markdownString: String) {
        var markdown = Markdown()
        let html = markdown.transform(markdownString)
        self.detailHTML = Theme.pageFromHTMLSnippet(html)
        self.message = nil
        self.buttonTitle = nil
    }
}