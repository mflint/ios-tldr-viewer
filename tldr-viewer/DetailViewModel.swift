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
    var message: NSAttributedString?
    var loading: Bool = false
    
    // tldr page in HTML
    var detailHTML: [Int:String] = [:]
    var currentDetailHTML : String?
    
    // multi-platforms
    var showPlatforms: Bool
    var platformOptions: [Platform] = []
    var selectedPlatform: Int
    
    private var command: Command!
    
    init(command: Command) {
        self.command = command
        
        self.navigationBarTitle = self.command.name
        self.showPlatforms = self.command.platforms.count > 1
        self.platformOptions = self.command.platforms
        self.selectedPlatform = 0
        
        self.loadDetail()
        self.update()
    }
    
    private func loadDetail() {
        let selectedPlatform = self.selectedPlatform
        
        if (self.detailHTML[self.selectedPlatform] == nil) {
            self.message = Theme.detailAttributed("Loading...")
            self.loading = true
            
            let urlString = "https://raw.githubusercontent.com/tldr-pages/tldr/master/pages/" + platformOptions[selectedPlatform].name + "/" + self.command.name + ".md"
            TLDRRequest.requestWithURL(urlString) { response in
                let markdownString = response.responseString
                
                var markdown = Markdown()
                let html = markdown.transform(markdownString!)
                self.detailHTML[selectedPlatform] = Theme.pageFromHTMLSnippet(html)
                self.message = nil
                self.loading = false
                
                self.update()
            }
        }
    }
    
    private func update() {
        self.currentDetailHTML = self.detailHTML[self.selectedPlatform]
        self.updateSignal()
    }
    
    func selectPlatform(platformIndex: NSInteger) {
        self.selectedPlatform = platformIndex
        self.loadDetail()
        self.update()
    }
}