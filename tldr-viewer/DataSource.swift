//
//  DataSource.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 23/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation
import Zip

public class DataSource: DataSourcing {
    private let documentsDirectory : URL!
    private let zipFileURL : URL!
    private let indexFileURL : URL!
    
    private var delegates = WeakCollection<DataSourceDelegate>()
    
    private(set) var commands = [Command]() {
        didSet {
            commandsByName = [String:Command]()
            delegates.forEach { (delegate) in
                delegate.dataSourceDidUpdate(dataSource: self)
            }
            
            // now update the looup table in the background
            DispatchQueue.global().async {
                self.commandsByName = self.commands.reduce(into: [String: Command](), { (result, command) in
                    result[command.name] = command
                })
            }
        }
    }
    let isSearchable = false
    let isRefreshable = true
    var requesting = false
    var requestError: String?

    private var commandsByName = [String:Command]()
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        zipFileURL = documentsDirectory.appendingPathComponent("tldr.zip")
        indexFileURL = documentsDirectory.appendingPathComponent("index.plist")
    }
    
    func add(delegate: DataSourceDelegate) {
        delegates.add(delegate)
    }
    
    /// loads the contents of the `index.plist` file. If the file cannot be read,
    /// then it begins a network request to refresh the data
    func loadInitialCommands() {
        if !loadCommandsFromIndexFile() {
            refresh()
        }
    }
    
    func refresh() {
        if requesting {
            return
        }
        
        requesting = true
        requestError = nil
        
        TLDRRequest.requestWithURL(urlString: "https://tldr.sh/assets/tldr.zip") { response in
            self.processResponse(response: response)
        }
        
        delegates.forEach { (delegate) in
            delegate.dataSourceDidUpdate(dataSource: self)
        }
    }
    
    func lastUpdateTime() -> Date? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: indexFileURL.path)
            return fileAttributes[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    func commandWith(name: String) -> Command? {
        return commandsByName[name] ?? nil
    }
    
    private func processResponse(response: TLDRResponse) {
        requesting = false
        
        if let error = response.error {
            handle(error: error)
        } else {
            handleSuccess(data: response.data)
        }
    }
    
    private func handle(error: Error) {
        requestError = Localizations.CommandList.Error.CouldNotDownload
        commands = []
    }
    
    private func handleSuccess(data: Data) {
        if !deleteExisting() {
            return
        }
        
        if !save(zipData:data) {
            return
        }
        
        if !unzipSavedFile() {
            return
        }
        
        if !indexCommandsFromDirectory() {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            self.addToSpotlightIndex()
        }
    }
    
    private func addToSpotlightIndex() {
        let spotlightSearch = SpotlightSearch()
        
        for command in self.commands {
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
        
        commands = indexFileContents
        
        return true
    }
    
    private func deleteExisting() -> Bool {
        do {
            // delete existing contents of documents directory
            let existingContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys:nil, options: [])
            for existingContent in existingContents {
                try FileManager.default.removeItem(at: existingContent)
            }
        } catch {
            requestError = Localizations.CommandList.Error.CouldNotSaveDownload
            return false
        }
        
        return true
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
    
    private func indexCommandsFromDirectory() -> Bool {
        do {
            // get an array of URLs for each markdown file
            var files = [URL]()
            try findMarkdownFiles(in: documentsDirectory, collect: &files)
            
            // get a sorted array of tuples
            // 0: markdown filename
            // 1: platform name
            // 2: pages folder with optional language code
            let sortedFiles = files.map { (url) -> (String, String, String) in
                let components = url.pathComponents.reversed()[0...2]
                return (components[0], components[1], components[2])
            }.sorted { (first, second) -> Bool in
                return first < second
            }
            
            // collapse that array into an array of Command objects
            let foundCommands = sortedFiles.reduce(into: [Command]()) { (results, pathComponents) in
                let commandName = pathComponents.0.replacingOccurrences(of: ".md", with: "")
                let platform = Platform.get(name: pathComponents.1)
                let languageCode = pathComponents.2
                
                // create a new Command if the last item in the list isn't the required one
                var command: Command
                if let lastCommand = results.last {
                    if lastCommand.name != commandName {
                        command = Command(name: commandName)
                        results.append(command)
                    } else {
                        command = lastCommand
                    }
                } else {
                    command = Command(name: commandName)
                    results.append(command)
                }
                
                // create a new CommandVariant if the last variant in this command
                // isn't the required one
                var variant: CommandVariant
                if let lastVariant = command.variants.last {
                    if lastVariant.platform != platform {
                        variant = CommandVariant(commandName: commandName, platform: platform)
                        command.variants.append(variant)
                    } else {
                        variant = lastVariant
                    }
                } else {
                    variant = CommandVariant(commandName: commandName, platform: platform)
                    command.variants.append(variant)
                }
                
                // add language code to the variant
                variant.languageCodes.append(languageCode)
                
                // and update the [Command] struct
                command.variants[command.variants.count - 1] = variant
                results[results.count - 1] = command
            }
            
            commands = foundCommands
            
            // now write the command array to a plist
            let encodedCommandIndex = try! PropertyListEncoder().encode(commands)
            try encodedCommandIndex.write(to: indexFileURL)

            return true
        }
        catch {
            commands = []
            requestError = Localizations.CommandList.Error.CouldNotIndexFiles
            return false
        }
    }
    
    private func findMarkdownFiles(in directory: URL, collect: inout [URL]) throws {
        let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
        for content in contents {
            var isDirectory : ObjCBool = false
            if FileManager.default.fileExists(atPath: content.relativePath, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    try findMarkdownFiles(in: content, collect: &collect)
                } else if content.absoluteString.contains(".md") {
                    collect.append(content)
                }
            }
        }
    }
    
    private func indexFileContents() -> [Command]? {
        do {
            let indexData = try Data(contentsOf: indexFileURL)
            return try PropertyListDecoder().decode([Command].self, from: indexData)
        }  catch {
            requestError = Localizations.CommandList.Error.CouldNotReadIndexFile
        }
        
        return nil
    }
}
