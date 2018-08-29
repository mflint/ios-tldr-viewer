//
//  DetailViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 30/12/2015.
//  Copyright © 2015 Green Light. All rights reserved.
//

import UIKit
import WebKit
import CoreSpotlight

class DetailViewController: UIViewController {
    @IBOutlet weak var platformsSegmentedControl: UISegmentedControl!

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var webView: WKWebView!
    
    // these two conflicting constraints adjust the layout depending on whether the segmented control is shown. Only one should be enabled
    var webViewToTopAnchorConstraint: NSLayoutConstraint!
    var webViewToSegmentedControlConstraint: NSLayoutConstraint!

    var viewModel: DetailViewModel? {
        didSet {
            viewModel?.updateSignal = {
                self.configureView()
            }
            viewModel?.setPasteboardValue = { value in
                UIPasteboard.general.string = value
            }
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(self, forURLScheme: "tldr")
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        // disable webview magnification
        self.webView.scrollView.delegate = self
        self.webView.navigationDelegate = self
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        
        self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        // two top constraints for the web view
        self.webViewToTopAnchorConstraint = self.webView.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.webViewToSegmentedControlConstraint = self.webView.topAnchor.constraint(equalTo: self.platformsSegmentedControl.bottomAnchor, constant: 3)
        
        self.messageView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let viewModel = viewModel else { return }
        
        viewModel.onCommandDisplayed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel?.onCommandHidden()
    }
    
    @IBAction func platformSegmentDidChange(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        
        viewModel.select(platformIndex: self.platformsSegmentedControl.selectedSegmentIndex)
    }
    
    private func configureView() {
        if viewIfLoaded == nil {
            return
        }
        
        DispatchQueue.main.async {
            self.doConfigureView()
        }
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
            message = Theme.detailAttributed(string: Localizations.CommandDetail.NothingSelected)
            htmlString = nil
            sceneTitle = ""
        }
        
        if let messageToShow = message {
            self.messageLabel.attributedText = messageToShow
            self.messageView.isHidden = false
            
            self.messageView.setNeedsLayout()
        } else {
            self.messageView.isHidden = true
        }
        
        if let htmlStringToShow = htmlString {
            self.webView.loadHTMLString(htmlStringToShow, baseURL: nil)
            self.webView.isHidden = false
        } else {
            self.webView.isHidden = true
        }
        
        self.title = sceneTitle
        self.doShowOrHideSegmentedControl(showSegmentedControl)
        
        if let viewModel = viewModel {
            let imageLarge = UIImage(imageLiteralResourceName: viewModel.favouriteButtonIconLarge)
            let imageSmall = UIImage(imageLiteralResourceName: viewModel.favouriteButtonIconSmall)
            let favouriteButton = UIBarButtonItem(image: imageLarge, landscapeImagePhone: imageSmall, style: .plain, target: self, action: #selector(DetailViewController.onFavouriteToggled))
            navigationItem.rightBarButtonItem = favouriteButton
        }
    }
    
    @objc private func onFavouriteToggled() {
        viewModel?.onFavouriteToggled()
    }
    
    private func doConfigureSegmentedControl(_ viewModel: DetailViewModel) {
        self.platformsSegmentedControl.removeAllSegments()
        
        for (index, platform) in viewModel.platforms.enumerated() {
            self.platformsSegmentedControl.insertSegment(withTitle: platform.platformName, at: index, animated: false)
        }
        
        self.platformsSegmentedControl.selectedSegmentIndex = viewModel.selectedPlatform.platformIndex
    }
    
    private func doShowOrHideSegmentedControl(_ show: Bool) {
        self.webViewToSegmentedControlConstraint.isActive = false
        self.webViewToTopAnchorConstraint.isActive = false
        
        self.platformsSegmentedControl.isHidden = !show
        self.webViewToSegmentedControlConstraint.isActive = show
        self.webViewToTopAnchorConstraint.isActive = !show
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension DetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let viewModel = viewModel else { return }
        
        let absoluteURLString = navigationAction.request.url!.absoluteString
        if viewModel.handleAbsoluteURL(absoluteURLString) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
}

extension DetailViewController: WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        if let url = urlSchemeTask.request.url {
            viewModel?.handleTapExampleUrl(url)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}
