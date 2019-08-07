//
//  CommandBuilder.swift
//  tldr-pages-tests
//
//  Created by Matthew Flint on 04/08/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import Foundation
@testable import tldr_viewer

enum TestPlatform: String {
    case common, linux, osx, windows
}

extension Command {
    func with(platform platformType: TestPlatform, languages: String...) -> Command {
        var command = self
        let platform = Platform.get(name: platformType.rawValue)
        let variant = CommandVariant(commandName: name, platform: platform, languageCodes: languages)
        command.variants.append(variant)
        return command
    }
}
