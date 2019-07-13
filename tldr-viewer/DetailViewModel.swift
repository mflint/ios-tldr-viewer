//
//  DetailViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

protocol DetailViewModelDelegate: class {
    /// the "favourite" status of the command has changed, and should be redrawn
    func updateFavourite()
    
    /// the command has changed, so the title and list of platforms should be redrawn
    func updateCommand()
    
    /// the selected platform has changed, so the html content should be redrawn
    func updatePlatformContent()
}

class DetailViewModel {
    weak var delegate: DetailViewModelDelegate?
    
    // set a value in the UIKit pasteboard
    var setPasteboardValue: (String, String) -> Void = { value, message in }
    
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
    var selectedPlatform: DetailPlatformViewModel! {
        didSet {
            delegate?.updatePlatformContent()
        }
    }
    
    var favourite: Bool = false
    var favouriteButtonIconSmall: String!
    var favouriteButtonIconLarge: String!
    private let dataSource: SearchableDataSourceType
    
    private var command: Command! {
        didSet {
            self.navigationBarTitle = self.command.name
            
            setupFavourite()
            delegate?.updateCommand()
            delegate?.updateFavourite()
            
            var platforms: [DetailPlatformViewModel] = []
            for (index, platform) in self.command.platforms.enumerated() {
                let platformVM = DetailPlatformViewModel(dataSource: dataSource, command: self.command, platform: platform, platformIndex: index)
                platforms.append(platformVM)
            }
            
            self.platforms = platforms
        }
    }
    
    init(dataSource: SearchableDataSourceType, command: Command) {
        self.dataSource = dataSource
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewModel.externalCommandChange(notification:)), name: Constant.ExternalCommandChangeNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewModel.favouriteChange(notification:)), name: Constant.FavouriteChangeNotification.name, object: nil)
        
        defer {
            self.command = command
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func select(platformIndex: Int) {
        if (platformIndex >= 0 && platformIndex <= self.platforms.count-1) {
            self.selectedPlatform = self.platforms[platformIndex]
            delegate?.updatePlatformContent()
        }
    }
    
    func onCommandDisplayed() {
        Preferences.sharedInstance.addLatest(command.name)
        Shortcuts.recreate()
        NotificationCenter.default.post(name: Constant.DetailViewPresence.shownNotificationName, object: nil)
    }
    
    func onCommandHidden() {
        NotificationCenter.default.post(name: Constant.DetailViewPresence.hiddenNotificationName, object: nil)
    }
    
    func onFavouriteToggled() {
        if favourite {
            FavouriteDataSource.sharedInstance.remove(commandName: command.name)
        } else {
            FavouriteDataSource.sharedInstance.add(commandName: command.name)
        }
    }
    
    func handleTapExampleUrl(_ url: URL) {
        let path = url.path
        let numberIndex = path.index(path.startIndex, offsetBy: 1)
        let numberString = path[numberIndex...]
        if let number = Int(numberString),
            let example = selectedPlatform.example(at: number) {
            setPasteboardValue(example, Localizations.CommandDetail.CopiedToPasteboard)
        }
    }
    
    func handleAbsoluteURL(_ absoluteURLString: String) -> Bool {
        if dataSource.commandWith(name: absoluteURLString) != nil {
            // command exists, so handle it here
            NotificationCenter.default.post(name: Constant.ExternalCommandChangeNotification.name, object: nil, userInfo: [Constant.ExternalCommandChangeNotification.commandNameKey : absoluteURLString as NSSecureCoding])
            return false
        }
        
        // command doesn't exist, so this ViewModel cannot handle it
        // return true so the ViewController handles it
        return true
    }
    
    @objc func externalCommandChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let commandName = userInfo[Constant.ExternalCommandChangeNotification.commandNameKey] as? String else { return }
        
        if let command = DataSource.sharedInstance.commandWith(name: commandName) {
            self.command = command
            onCommandDisplayed()
        }
    }
    
    @objc func favouriteChange(notification: Notification) {
        setupFavourite()
        delegate?.updateFavourite()
    }
    
    private func setupFavourite() {
        favourite = FavouriteDataSource.sharedInstance.favouriteCommandNames.contains(command.name)
        favouriteButtonIconSmall = favourite ? "heart-small" : "heart-o-small"
        favouriteButtonIconLarge = favourite ? "heart-large" : "heart-o-large"
    }
}
