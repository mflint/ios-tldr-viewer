//
//  SectionViewModel.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 05/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import Foundation

class SectionViewModel {
    var title = ""
    var cellViewModels = [BaseCellViewModel]()
    
    init(firstCellViewModel: BaseCellViewModel) {
        if let commandCellViewModel = firstCellViewModel as? CommandCellViewModel {
            title = self.titleForCommandCellViewModel(commandCellViewModel)
        }
        
        self.cellViewModels.append(firstCellViewModel)
    }
    
    private func titleForCommandCellViewModel(_ commandCellViewModel: CommandCellViewModel) -> String {
        let commandName = commandCellViewModel.command.name.lowercased()
        let firstCharacter = commandName.characters.first
        
        guard let first = firstCharacter else { return "#" }
        
        if first >= "a" && first <= "z" {
            return String(first)
        }
        
        return "#"
    }
    
    func accept(cellViewModel: BaseCellViewModel) -> Bool {
        guard let commandCellViewModel = cellViewModel as? CommandCellViewModel else {
            return false
        }
        
        let titleForCommandCellViewModel = self.titleForCommandCellViewModel(commandCellViewModel)
        if titleForCommandCellViewModel == self.title {
            self.cellViewModels.append(cellViewModel)
            return true
        }
        
        return false
    }
    
    class func sort(sections: [SectionViewModel]) -> [SectionViewModel] {
        return sections.sorted(by: { (first, second) -> Bool in
            switch(second.title) {
            case "#":
                return true
            default:
                return first.title.compare(second.title) == ComparisonResult.orderedAscending
            }
        })
    }
}
