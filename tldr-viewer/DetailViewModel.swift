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
    var navigationBarTitle: String = ""

    // multi-platforms
    var platforms: [DetailPlatformViewModel] = [] {
        didSet {
            self.showPlatforms = self.command.platforms.count > 1
            self.selectedPlatform = self.platforms[0]
        }
    }
    var showPlatforms: Bool = false
    var selectedPlatform: DetailPlatformViewModel!
    
    private var command: Command! {
        didSet {
            self.navigationBarTitle = self.command.name
            
            var platforms: [DetailPlatformViewModel] = []
            for (index, platform) in self.command.platforms.enumerated() {
                let platformVM = DetailPlatformViewModel(command: self.command, platform: platform, platformIndex: index)
                platforms.append(platformVM)
            }
            
            self.platforms = platforms
        }
    }
    
    init(command: Command) {
        defer {
            self.command = command
        }
    }
    
    func select(platformIndex: Int) {
        if (platformIndex >= 0 && platformIndex <= self.platforms.count-1) {
            self.selectedPlatform = self.platforms[platformIndex]
            updateSignal()
        }
    }
    
    func onCommandDisplayed() {
        Preferences.sharedInstance.addLatest(command.name)
        Shortcuts.recreate()
    }
    
    func showCommand(commandName: String) {
        if let command = DataSource.sharedInstance.commandWith(name: commandName) {
            self.command = command
        }
    }
}
