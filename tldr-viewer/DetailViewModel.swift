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
    
    var detailAttributedText: NSAttributedString
    private var command: Command!
    
    init(command: Command) {
        self.command = command
        self.detailAttributedText = NSAttributedString.init(string: self.command.name)
        self.loadDetail()
    }
    
    func loadDetail() {
        let urlString = "https://raw.githubusercontent.com/tldr-pages/tldr/master/pages/" + self.command.platforms[0] + "/" + self.command.name + ".md"
        TLDRRequest.requestWithURL(urlString) { response in
            self.detailAttributedText = NSAttributedString.init(string: response.responseString!)
        }
    }
}