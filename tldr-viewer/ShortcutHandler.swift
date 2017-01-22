//
//  ShortcutHandler.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 22/01/2017.
//  Copyright © 2017 Green Light. All rights reserved.
//

import Foundation
import UIKit

protocol ShortcutHandler {
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem)
}
