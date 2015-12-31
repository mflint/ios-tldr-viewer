//
//  ListViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

class ListViewModel {
    var updateSignal: () -> Void = {}
    
    internal var cellViewModels = [BaseCellViewModel]()
    
    init() {
        self.loadIndex()
    }
    
    func loadIndex() {
        TLDRRequest.requestWithURL("https://raw.githubusercontent.com/tldr-pages/tldr-pages.github.io/master/assets/index.json") { response in
            if let jsonDict = response.responseJSON as? Dictionary<String, Array<Dictionary<String, AnyObject>>> {
                var commands = [Command]()
                
                for commandJSON in jsonDict["commands"]! {
                    let name = commandJSON["name"] as! String
                    let platforms = commandJSON["platform"] as! Array<String>
                    let command = Command(name: name , platforms: platforms)
                    
                    commands.append(command)
                }
                
                self.updateCellViewModels(commands)
            }
        }
    }
    
    func updateCellViewModels(commands: [Command]) {
        var vms = [BaseCellViewModel]()
        
        for command in commands {
            let cellViewModel = CommandCellViewModel(command: command)
            vms.append(cellViewModel)
        }
        
        self.cellViewModels = vms
        self.updateSignal()
    }
}
