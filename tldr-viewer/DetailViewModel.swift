//
//  DetailViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 31/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

protocol DetailViewModelDelegate: AnyObject {
    /// the "favourite" status of the command has changed, and should be redrawn
    func updateFavourite()
    
    /// the command has changed, so the title and list of platforms should be redrawn
    func updateCommand()
    
    /// the selected platform has changed, so the html content should be redrawn
    func updatePlatformContent()
}

/// `DetailViewModel` is the ViewModel for the detail screen. It contains one or more
/// `DetailPlatformViewModel` objects, which hold the actual tldr text for a single
/// variant of the current Command
class DetailViewModel {
    weak var delegate: DetailViewModelDelegate?
    
    // set a value in the UIKit pasteboard
    var setPasteboardValue: (String, String) -> Void = { value, message in }
    
    // navigation bar title
    var navigationBarTitle: String = ""

    // ViewModels for this Command's Variants
    var variantViewModels: [DetailPlatformViewModel] = [] {
        didSet {
            showVariants = command.variants.count > 1
            selectedVariantIndex = 0
        }
    }
    var showVariants: Bool = false
    var selectedVariantIndex: Int!  {
        didSet {
            delegate?.updatePlatformContent()
        }
    }
    var selectedVariant: DetailPlatformViewModel {
        get {
            return variantViewModels[selectedVariantIndex]
        }
    }
    
    var favourite: Bool = false
    var favouriteButtonIconSmall: String!
    var favouriteButtonIconLarge: String!
    
    private var command: Command! {
        willSet {
            selectedVariantIndex = 0
        }
        didSet {
            self.navigationBarTitle = self.command.name
            
            setupFavourite()
            delegate?.updateCommand()
            delegate?.updateFavourite()
            
            var variantViewModels = [DetailPlatformViewModel]()
            for variant in command.variants {
                let platformVM = DetailPlatformViewModel(commandVariant: variant)
                variantViewModels.append(platformVM)
            }
            
            self.variantViewModels = variantViewModels
        }
    }
    
    init(command: Command) {
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewModel.externalCommandChange(notification:)), name: Constant.ExternalCommandChangeNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewModel.favouriteChange(notification:)), name: Constant.FavouriteChangeNotification.name, object: nil)
        
        defer {
            self.command = command
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func select(variantIndex: Int) {
        if (variantIndex >= 0 && variantIndex <= variantViewModels.count-1) {
            selectedVariantIndex = variantIndex
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
        let favourtes = DataSources.sharedInstance.favouritesDataSource
        
        if favourite {
            favourtes.remove(commandName: command.name)
        } else {
            favourtes.add(commandName: command.name)
        }
    }
    
    func handleTapExampleUrl(_ url: URL) {
        let path = url.path
        let numberIndex = path.index(path.startIndex, offsetBy: 1)
        let numberString = path[numberIndex...]
        if let number = Int(numberString),
            let example = selectedVariant.example(at: number) {
            setPasteboardValue(example, Localizations.CommandDetail.CopiedToPasteboard)
        }
    }
    
    /// handle a user tap on a hyperlink, while viewing command details
    /// - Parameter absoluteURLString: the tapped URL string (which might match a command-name)
    func handleAbsoluteURL(_ absoluteURLString: String) -> Bool {
        // TODO: handle variants
        let dataSource = DataSources.sharedInstance.baseDataSource
        if dataSource.commandWith(name: absoluteURLString) != nil {
            // command exists, so handle it here
            NotificationCenter.default.post(name: Constant.ExternalCommandChangeNotification.name, object: nil, userInfo: [Constant.ExternalCommandChangeNotification.commandNameKey : absoluteURLString as NSSecureCoding])
            return false
        }
        
        // command doesn't exist, so this ViewModel cannot handle it
        // return true so the ViewController handles it
        return true
    }
    
    /// Something caused the selected command to change, and this function handles that change
    /// - Parameter notification: notification containing the new command details
    @objc func externalCommandChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let commandName = userInfo[Constant.ExternalCommandChangeNotification.commandNameKey] as? String else { return }

        // TODO: handle variants
        if let command = DataSources.sharedInstance.baseDataSource.commandWith(name: commandName) {
            self.command = command
            onCommandDisplayed()
        }
    }
    
    @objc func favouriteChange(notification: Notification) {
        setupFavourite()
        delegate?.updateFavourite()
    }
    
    private func setupFavourite() {
        favourite = DataSources.sharedInstance.favouritesDataSource.isFavourite(commandName: command.name)
        favouriteButtonIconSmall = favourite ? "heart-small" : "heart-o-small"
        favouriteButtonIconLarge = favourite ? "heart-large" : "heart-o-large"
    }
}
