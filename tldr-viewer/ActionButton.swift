//
//  ActionButton.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 01/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    override func awakeFromNib() {
        self.backgroundColor = UIColor.tldrActionBackground()
        self.layer.cornerRadius = 2
        self.titleLabel?.font = UIFont.tldrBody()
        self.setTitleColor(UIColor.tldrActionForeground(), for: .normal)
        self.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
    }
}
