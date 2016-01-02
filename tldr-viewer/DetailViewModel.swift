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

    // multi-platforms
    var showPlatforms: Bool
    var platforms: [DetailPlatformViewModel] = []
    var selectedPlatform: DetailPlatformViewModel!
    
    private var command: Command!
    
    init(command: Command) {
        self.command = command
        
        self.navigationBarTitle = self.command.name
        self.showPlatforms = self.command.platforms.count > 1
        
        let childUpdateSignal = {
            self.updateSignal()
        }
        for (index, platform) in self.command.platforms.enumerate() {
            let platformVM = DetailPlatformViewModel(updateSignal: childUpdateSignal, command: self.command, platform: platform, platformIndex: index)
            self.platforms.append(platformVM)
        }
        self.selectedPlatform = self.platforms[0]
        
        self.selectedPlatform.loadDetailIfRequired()
    }
    
    func selectPlatform(platformIndex: Int) {
        if (platformIndex >= 0 && platformIndex <= self.platforms.count-1) {
            self.selectedPlatform = self.platforms[platformIndex]
            self.selectedPlatform.loadDetailIfRequired()
        }
    }
}