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
    var buttonTitle: String?
    
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
        
        self.loadDetailIfRequired()
    }
    
    func reloadDetail() {
        let selectedPlatform = self.selectedPlatform
        
        self.doLoadDetail(selectedPlatform)
    }
    
    private func loadDetailIfRequired() {
        let selectedPlatform = self.selectedPlatform
        
        if (self.detailHTML[selectedPlatform] == nil) {
            self.doLoadDetail(selectedPlatform)
        }
    }
    
    private func doLoadDetail(loadingPlatform: Int) {
        self.message = Theme.detailAttributed("Loading...")
        self.buttonTitle = nil
        self.loading = true
        
        let urlString = "https://raw.githubusercontent.com/tldr-pages/tldr/master/pages/" + platformOptions[selectedPlatform].name + "/" + self.command.name + ".md"
        TLDRRequest.requestWithURL(urlString) { response in
            self.processResponse(response, loadingPlatform: loadingPlatform)
        }
        
        self.update()
    }
    
    private func processResponse(response: TLDRResponse, loadingPlatform: Int) {
        self.loading = false
        
        if let error = response.error {
            self.handleError(error)
        } else if let markdownString = response.responseString {
            self.handleSuccess(markdownString, loadingPlatform: loadingPlatform)
        }
        
        self.update()
    }
    
    private func handleError(error: NSError) {
        self.message = Theme.detailAttributed("Could not fetch the tldr-page")
        self.buttonTitle = "Try again"
    }
    
    private func handleSuccess(markdownString: String, loadingPlatform: Int) {
        var markdown = Markdown()
        let html = markdown.transform(markdownString)
        self.detailHTML[loadingPlatform] = Theme.pageFromHTMLSnippet(html)
        self.message = nil
        self.buttonTitle = nil
    }
    
    private func update() {
        self.currentDetailHTML = self.detailHTML[self.selectedPlatform]
        self.updateSignal()
    }
    
    func selectPlatform(platformIndex: NSInteger) {
        self.selectedPlatform = platformIndex
        self.loadDetailIfRequired()
        self.update()
    }
}