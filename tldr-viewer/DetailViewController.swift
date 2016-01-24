//
//  DetailViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    @IBOutlet weak var platformsSegmentedControl: UISegmentedControl!

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var webView: WKWebView!
    
    // these two conflicting constraints adjust the layout depending on whether the segmented control is shown. Only one should be enabled
    var webViewToTopAnchorConstraint: NSLayoutConstraint!
    var webViewToSegmentedControlConstraint: NSLayoutConstraint!

    var viewModel: DetailViewModel! {
        didSet {
            self.viewModel.updateSignal = {
                self.configureView()
            }
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: CGRectZero, configuration: configuration)
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        
        self.webView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
        self.webView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        self.webView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true

        // two top constraints for the web view
        self.webViewToTopAnchorConstraint = self.webView.topAnchor.constraintEqualToAnchor(self.view.topAnchor)
        self.webViewToSegmentedControlConstraint = self.webView.topAnchor.constraintEqualToAnchor(self.platformsSegmentedControl.bottomAnchor, constant: 3)
        
        self.messageView.hidden = true
        
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.configureView()
    }
    
    @IBAction func platformSegmentDidChange(sender: AnyObject) {
        self.viewModel.selectPlatform(self.platformsSegmentedControl.selectedSegmentIndex)
    }
    
    private func configureView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.doConfigureView()
        })
    }
    
    private func doConfigureView() {
        var htmlString: String?
        var message: NSAttributedString?
        var sceneTitle: String
        var showSegmentedControl = false

        if let viewModel = self.viewModel, let platformViewModel = viewModel.selectedPlatform {
            if (platformViewModel.message != nil) {
                message = platformViewModel.message
                htmlString = nil
            } else {
                message = nil
                htmlString = platformViewModel.detailHTML!
            }
            sceneTitle = viewModel.navigationBarTitle
            
            showSegmentedControl = viewModel.showPlatforms
            if (showSegmentedControl) {
                self.doConfigureSegmentedControl(viewModel)
            }
        } else {
            message = Theme.detailAttributed("Nothing selected")
            htmlString = nil
            sceneTitle = ""
        }
        
        if let messageToShow = message {
            self.messageLabel.attributedText = messageToShow
            self.messageView.hidden = false
            
            self.messageView.setNeedsLayout()
        } else {
            self.messageView.hidden = true
        }
        
        if let htmlStringToShow = htmlString {
            self.webView.loadHTMLString(htmlStringToShow, baseURL: nil)
            self.webView.hidden = false
        } else {
            self.webView.hidden = true
        }
        
        self.title = sceneTitle
        self.doShowOrHideSegmentedControl(showSegmentedControl)
    }
    
    private func doConfigureSegmentedControl(viewModel: DetailViewModel) {
        self.platformsSegmentedControl.removeAllSegments()
        
        for (index, platform) in viewModel.platforms.enumerate() {
            self.platformsSegmentedControl.insertSegmentWithTitle(platform.platformName, atIndex: index, animated: false)
        }
        
        self.platformsSegmentedControl.selectedSegmentIndex = viewModel.selectedPlatform.platformIndex
    }
    
    private func doShowOrHideSegmentedControl(show: Bool) {
        self.webViewToSegmentedControlConstraint.active = false
        self.webViewToTopAnchorConstraint.active = false
        
        self.platformsSegmentedControl.hidden = !show
        self.webViewToSegmentedControlConstraint.active = show
        self.webViewToTopAnchorConstraint.active = !show
    }
}
