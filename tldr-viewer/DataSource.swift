//
//  DataSource.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 23/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation
import Zip

public class DataSource {
    private let documentsDirectory : NSURL!
    private let zipFileURL : NSURL!
    private let indexFileURL : NSURL!
    
    // no-op closures until the ViewModel provides its own
    var updateSignal: () -> Void = {}
    var requesting = false
    var requestError: String?
    var commands = [Command]()
    
    init() {
        documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        zipFileURL = documentsDirectory.URLByAppendingPathComponent("tldr.zip")
        indexFileURL = documentsDirectory.URLByAppendingPathComponent("pages").URLByAppendingPathComponent("index.json")
        
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
        
        TLDRRequest.requestWithURL("https://tldr-pages.github.io/assets/tldr.zip") { response in
            self.processResponse(response)
        }
        
        updateSignal()
    }
    
    func lastUpdateTime() -> NSDate? {
        guard let path = indexFileURL.path else {
            return nil
        }
        
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
            return fileAttributes[NSFileModificationDate] as? NSDate
        } catch {
            return nil
        }
    }
    
    private func processResponse(response: TLDRResponse) {
        if let error = response.error {
            handleError(error)
        } else {
            handleSuccess(response.data)
        }
        
        requesting = false
        updateSignal()
    }
    
    private func handleError(error: NSError) {
        requestError = "Could not download tl;dr file"
    }
    
    private func handleSuccess(data: NSData) {
        if !saveZipData(data) {
            return
        }
        
        if !unzipSavedFile() {
            return
        }
        
        loadCommandsFromIndexFile()
    }
    
    private func loadCommandsFromIndexFile() -> Bool {
        guard let indexFileContents = indexFileContents() else {
            return false
        }
        
        if indexFileContents.count == 0 {
            return false
        }
        
        self.commands = commandsFromIndexFile(indexFileContents)
        
        return true
    }
    
    private func saveZipData(data: NSData) -> Bool {
        if !data.writeToURL(zipFileURL, atomically: true) {
            requestError = "Could not save the download"
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
            requestError = "Could not unzip the dwnload"
            return false
        }
    }
    
    private func indexFileContents() -> Array<Dictionary<String, AnyObject>>? {
        let indexDataOptional = NSData(contentsOfURL: indexFileURL)
        guard let indexData = indexDataOptional else {
            requestError = "Could not find index file"
            return nil
        }
        
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(indexData, options: [])
            
            // sometimes we get an array as the top level object...
            if let jsonResult = jsonResult as? Array<Dictionary<String, AnyObject>> {
                return jsonResult
            }
            
            // ... sometimes that array is inside a map ¯\_(ツ)_/¯
            if let jsonResult = jsonResult as? Dictionary<String, Array<Dictionary<String, AnyObject>>> {
                return jsonResult["commands"]
            }
        }  catch let error as NSError {
            requestError = "Could not read index file"
            print (error)
        }
        
        return nil
    }
    
    private func commandsFromIndexFile(jsonArray: Array<Dictionary<String, AnyObject>>) -> [Command] {
        var commands = [Command]()
        
        for commandJSON in jsonArray {
            let name = commandJSON["name"] as! String
            var platforms = [Platform]()
            for platformName in commandJSON["platform"] as! Array<String> {
                let platform = Platform.get(platformName)
                platforms.append(platform)
            }
            let command = Command(name: name , platforms: Platform.sort(platforms))
            
            commands.append(command)
        }
        
        return commands
    }
}