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
    var webView: WKWebView!

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
        self.webView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.configureView()
    }
    
    func configureView() {
        if (self.webView != nil) {
            dispatch_async(dispatch_get_main_queue(), {
                if let viewModel = self.viewModel {
                    if viewModel.detailHTML == nil {
                        self.webView.loadHTMLString(viewModel.noDataMessage, baseURL: nil)
                    } else {
                        self.webView.loadHTMLString(viewModel.detailHTML!, baseURL: nil)
                    }
                    
                    self.title = self.viewModel.navigationBarTitle
                } else {
                    self.webView.loadHTMLString("Nothing selected", baseURL: nil)
                    self.title = ""
                }
            })
        } else {
            if let viewModel = self.viewModel {
                self.title = viewModel.navigationBarTitle
            }
        }
    }
}

