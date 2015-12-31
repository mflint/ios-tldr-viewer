//
//  ListViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import Foundation

class ListViewModel {
    // no-op closures until the ViewController provides its own
    var updateSignal: () -> Void = {}
    var showDetail: (detailViewModel: DetailViewModel) -> Void = {(vm) in}
    
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
            let cellViewModel = CommandCellViewModel(command: command, action: {
                let detailViewModel = DetailViewModel(command: command)
                self.showDetail(detailViewModel: detailViewModel)
            })
            vms.append(cellViewModel)
        }
        
        self.cellViewModels = vms
        self.updateSignal()
    }
    
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) {
        self.cellViewModels[indexPath.row].performAction()
    }
}
