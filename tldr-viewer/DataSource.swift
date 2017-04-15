//
//  DataSource.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 23/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation
import Zip

public class DataSource: DataSourceType, RefreshableDataSourceType, SearchableDataSourceType {

    private let documentsDirectory : URL!
    private let zipFileURL : URL!
    private let indexFileURL : URL!
    
    static let sharedInstance = DataSource()
    let name = Localizations.CommandList.DataSources.All
    let type = Preferences.DataSourceEnumType.all
    
    // no-op closures until the ViewModel provides its own
    var updateSignal: () -> Void = {}
    var requesting = false
    var requestError: String?
    
    // the complete unfiltred list
    private var allCommandsList = [Command]()
    
    // the list with platform-specific stuff filtered out
    private var allListableCommandsList = [Command]()
    private var requiredPlatformNames: [String]!
    
    var platforms: [Platform]?
    
    private var spotlistIndexPending = false
    private var spotlightIndexRunning = false
    
    private init() {
        // TODO: load from prefs
        requiredPlatformNames = ["common"]
        
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        zipFileURL = documentsDirectory.appendingPathComponent("tldr.zip")
        indexFileURL = documentsDirectory.appendingPathComponent("pages").appendingPathComponent("index.json")
        
        if !loadCommandsFromIndexFile() {
            beginRequest()
        }
    }
    
    func beginRequest() {
        if requesting {
            return
        }
        
        requesting = true
        requestError = nil
        
        TLDRRequest.requestWithURL(urlString: "https://tldr-pages.github.io/assets/tldr.zip") { response in
            self.processResponse(response: response)
        }
        
        updateSignal()
    }
    
    func lastUpdateTime() -> Date? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: indexFileURL.path)
            return fileAttributes[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    func allCommands() -> [Command] {
        return allCommandsList
    }
    
    func allListableCommands() -> [Command] {
        return allListableCommandsList
    }
    
    func listableCommandsWith(filter: String) -> [Command] {
        // if the search string is empty, return everything
        if filter.characters.count == 0 {
            return allListableCommandsList
        }
        
        let lowercasedFilter = filter.lowercased()
        return listableCommandsWith(filter: { (command) -> Bool in
            return command.name.lowercased().contains(lowercasedFilter)
        })
    }
    
    private func listableCommandsWith(filter: (Command) -> Bool) -> [Command] {
        return allListableCommandsList.filter(filter)
    }
    
    func commandsWith(filter: (Command) -> Bool) -> [Command] {
        return allCommandsList.filter(filter)
    }
    
    func commandWith(name: String) -> Command? {
        let foundCommands = allCommandsList.filter{ command in
            return command.name == name
        }
        
        return foundCommands.count > 0 ? foundCommands[0] : nil
    }
    
    private func processResponse(response: TLDRResponse) {
        if let error = response.error {
            handle(error: error)
        } else {
            handleSuccess(data: response.data)
        }
        
        requesting = false
        updateSignal()
    }
    
    private func handle(error: Error) {
        requestError = Localizations.CommandList.Error.CouldNotDownload
    }
    
    private func handleSuccess(data: Data) {
        if !save(zipData:data) {
            return
        }
        
        if !unzipSavedFile() {
            return
        }
    }
    
    private func addToSpotlightIndex() {
        spotlistIndexPending = true
        
        if spotlightIndexRunning {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            self.spotlightIndexRunning = true
            
            while(self.spotlistIndexPending) {
                self.spotlistIndexPending = false
                self.addToSpotlightIndex()
            }
            
            self.spotlightIndexRunning = false
        }
    }
    
    private func doAddToSpotlightIndex() {
        let spotlightSearch = SpotlightSearch()
        
        for command in self.allListableCommandsList {
            spotlightSearch.addToIndex(command: command)
        }
    }
    
    private func loadCommandsFromIndexFile() -> Bool {
        guard let indexFileContents = indexFileContents() else {
            return false
        }
        
        if indexFileContents.count == 0 {
            return false
        }
        
        allCommandsList = commandsFrom(indexFile: indexFileContents)
        makeListableCommands()
        
        return true
    }
    
    func setRequiredPlatforms(platforms: [Platform]) {
        
    }
    
    private func makeListableCommands() {
        allListableCommandsList = allCommandsList.filter({ (command) -> Bool in
//            command.platforms.contains(where: { (commandPlatform) -> Bool in
//                self.requiredPlatformNames.contains(where: { (requiredPlatformName) -> Bool in
//                    requiredPlatformName == commandPlatform.name
//                })
//            })
            let matchingPlatformNames = command.platforms.map({ (platform) -> String in
                platform.name
            }).filter(requiredPlatformNames.contains)
            return matchingPlatformNames.count > 0
        })
        
        addToSpotlightIndex()
    }
    
    private func save(zipData: Data) -> Bool {
        do {
            try zipData.write(to: zipFileURL, options: (.atomic))
        } catch {
            requestError = Localizations.CommandList.Error.CouldNotSaveDownload
            return false
        }
        
        return true
    }
    
    private func unzipSavedFile() -> Bool {
        do {
            try Zip.unzipFile(zipFileURL, destination: documentsDirectory, overwrite: true, password: nil, progress: nil)
            return true
        }
        catch {
            requestError = Localizations.CommandList.Error.CouldNotUnzipDownload
            return false
        }
    }
    
    private func indexFileContents() -> Array<Dictionary<String, AnyObject>>? {
        
        do {
            let indexData = try Data(contentsOf: indexFileURL)
            let jsonResult = try JSONSerialization.jsonObject(with: indexData, options: [])
            
            // sometimes we get an array as the top level object...
            if let jsonResult = jsonResult as? Array<Dictionary<String, AnyObject>> {
                return jsonResult
            }
            
            // ... sometimes that array is inside a map ¯\_(ツ)_/¯
            if let jsonResult = jsonResult as? Dictionary<String, Array<Dictionary<String, AnyObject>>> {
                return jsonResult["commands"]
            }
        }  catch let error as NSError {
            requestError = Localizations.CommandList.Error.CouldNotReadIndexFile
            print (error)
        }
        
        return nil
    }
    
    private func commandsFrom(indexFile: Array<Dictionary<String, AnyObject>>) -> [Command] {
        var commands = [Command]()
        
        for commandJSON in indexFile {
            let name = commandJSON["name"] as! String
            var platforms = [Platform]()
            for platformName in commandJSON["platform"] as! Array<String> {
                let platform = Platform.get(name: platformName)
                platforms.append(platform)
            }
            let command = Command(name: name , platforms: Platform.sort(platforms: platforms))
            
            commands.append(command)
        }
        
        return commands
    }
}
