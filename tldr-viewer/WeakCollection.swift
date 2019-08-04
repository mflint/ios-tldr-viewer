//
//  WeakCollection.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation

struct WeakCollection<Element> {
    private struct WeakRef<T> where T: AnyObject {
        weak var value: T?
        init (value: T) {
            self.value = value
        }
    }
    
    private var array: [WeakRef<AnyObject>] = []
    
    var count: Int {
        return array.count
    }
    
    mutating private func clean() {
        array = array.filter({ (weakRef) -> Bool in
            weakRef.value != nil
        })
    }
    
    mutating func add(_ newElement: Element) {
        clean()
        if (!contains(newElement)) {
            array.append(WeakRef(value: newElement as AnyObject))
        }
    }
    
    private func contains(_ element: Element) -> Bool {
        var found = false
        
        array.forEach { (weakRef) in
            if let value = weakRef.value, value === (element as AnyObject) {
                found = true
            }
        }
        
        return found
    }
    
    mutating func remove(_ element: Element) {
        array = array.filter({ (weakRef) -> Bool in
            guard let value = weakRef.value else {
                return false
            }
            return value !== (element as AnyObject)
        })
    }
    
    func forEach(_ body: (Element) throws -> Void) rethrows {
        try array.forEach { (weakRef) in
            if let value = weakRef.value as? Element {
                try body(value)
            }
        }
    }
}
