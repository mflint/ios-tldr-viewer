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
        self.backgroundColor = Color.actionBackground.uiColor()
        self.layer.cornerRadius = 8
        self.titleLabel?.font = UIFont.tldrBody()
        self.setTitleColor(Color.actionForeground.uiColor(), for: .normal)
        self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
}
