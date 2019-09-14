//
//  SnapshotTests.swift
//  tldr-viewer-snapshottests
//
//  Created by Matthew Flint on 29/06/2019.
//  Copyright © 2019 Green Light. All rights reserved.
//

import XCTest

private struct Device {
    let name: String
    let splitView: Bool
    let phone: Bool
}

// for appstore screenshot requirements, see https://help.apple.com/app-store-connect/#/devd274dd925

private struct Devices {
    private static let devices = [
        Device(name: "iPhone Xʀ", splitView: true, phone: true),
        Device(name: "iPhone Xs Max", splitView: true, phone: true),
        Device(name: "iPhone Xs", splitView: false, phone: true),
        Device(name: "iPhone 8 Plus", splitView: true, phone: true),
        Device(name: "iPhone 8", splitView: false, phone: true),
        Device(name: "iPhone 5s", splitView: false, phone: true),
        Device(name: "iPhone SE", splitView: false, phone: true),
        Device(name: "iPad Pro (12.9-inch) (3rd generation)", splitView: true, phone: false),
        Device(name: "iPad Pro (12.9-inch) (2nd generation)", splitView: true, phone: false),
        Device(name: "iPad Pro (11-inch)", splitView: true, phone: false),
        Device(name: "iPad Pro (10.5-inch)", splitView: true, phone: false),
        Device(name: "iPad Pro (9.7-inch)", splitView: true, phone: false)
    ]
    
    static func currentDevice() -> Device {
        let name = UIDevice.current.name
        for device in Devices.devices {
            if device.name == name {
                return device
            }
        }
        
        XCTFail("device not known: \(name)")
        preconditionFailure()
    }
}

class SnapshotTests: XCTestCase {
    enum ScreenshotNames: String {
        case commandList = "01CommandList"
        case commandDetail = "02CommandDetail"
        case commandListAndDetail = "03CommandListAndDetail"
    }
    
    private var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testCommandList() {
        guard Devices.currentDevice().phone else { return }
        
        Thread.sleep(forTimeInterval: 3)
        
        app.buttons["All"].firstMatch.tap()
        
        snapshot(ScreenshotNames.commandList.rawValue)
    }
    
    func testCommandDetail() {
        Thread.sleep(forTimeInterval: 3)
        
        app.buttons["All"].firstMatch.tap()
        app.staticTexts["say"].firstMatch.tap()

        Thread.sleep(forTimeInterval: 3)
        
        if Devices.currentDevice().phone {
            snapshot(ScreenshotNames.commandDetail.rawValue)
        } else {
            snapshot(ScreenshotNames.commandListAndDetail.rawValue)
        }
    }

}
