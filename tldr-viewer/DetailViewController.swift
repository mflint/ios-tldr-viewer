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

private class ToastLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialise()
    }
    
    private func initialise() {
        textColor = Color.bodyHighlight.uiColor()
        font = UIFont.tldrBody()
        preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.8
        numberOfLines = 0

        clipsToBounds = true
        layer.borderWidth = 2
        layer.borderColor = Color.bodyHighlight.uiColor().cgColor
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        isOpaque = true
        backgroundColor = Color.background.uiColor()
        
        invalidateIntrinsicContentSize()
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 15)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let superRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let adjusted = CGRect.insetBy(superRect)(dx: -30, dy: -10)
        return adjusted
    }
}


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
            viewModel?.delegate = self
            viewModel?.setPasteboardValue = { value, message in
                self.setPasteboard(string: value, message: message)
            }
            updateFavourite()
            updateCommand()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(self, forURLScheme: "tldr")
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .clear
        
        // disable webview magnification
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        // two top constraints for the web view
        webViewToTopAnchorConstraint = webView.topAnchor.constraint(equalTo: view.topAnchor)
        webViewToSegmentedControlConstraint = webView.topAnchor.constraint(equalTo: platformsSegmentedControl.bottomAnchor, constant: 3)
        
        messageView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavourite()
        updateCommand()
        updatePlatformContent()
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            // if the light/dark mode trait changes, then reconfigure the whole view
            // this will recreate the CSS and reload the webview
            let previousStyle = previousTraitCollection?.userInterfaceStyle
            
            if previousStyle != traitCollection.userInterfaceStyle {
                updatePlatformContent()
            }
        }
    }
    
    @IBAction func platformSegmentDidChange(_ sender: AnyObject) {
        guard let viewModel = viewModel else { return }
        
        viewModel.select(platformIndex: self.platformsSegmentedControl.selectedSegmentIndex)
    }
    
    private func setPasteboard(string: String, message: String) {
        DispatchQueue.main.async {
            self.doSetPasteboard(string: string, message: message)
        }
    }
        
    private func doSetPasteboard(string: String, message: String) {
        UIPasteboard.general.string = string
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        let toastLabel = ToastLabel()
        toastLabel.text = message
        toastLabel.sizeToFit()
        
        let x = (view.bounds.width - toastLabel.frame.width) / 2
        let height = toastLabel.frame.height
        toastLabel.frame = CGRect(x: x, y: -height, width: toastLabel.frame.width, height: toastLabel.frame.height)
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            toastLabel.frame = CGRect(x: x, y: 0, width: toastLabel.frame.width, height: toastLabel.frame.height)
        }) { (finished) in
            UIView.animate(withDuration: 0.35, delay: 2.5, options: .curveEaseInOut, animations: {
                toastLabel.frame = CGRect(x: x, y: -height, width: toastLabel.frame.width, height: toastLabel.frame.height)
            }, completion: { (finished) in
                toastLabel.removeFromSuperview()
            })
        }
    }
    
    private func doConfigureCommand() {
        if let viewModel = viewModel {
            if viewModel.showPlatforms {
                doConfigureSegmentedControl(viewModel)
                doShowOrHideSegmentedControl(true)
            } else {
                doShowOrHideSegmentedControl(false)
            }
        }
    }
    
    private func doConfigurePlatformContent() {
        var htmlString: String?
        var message: NSAttributedString?
        var sceneTitle: String

        if let viewModel = viewModel,
            let platformViewModel = viewModel.selectedPlatform {
            if (platformViewModel.message != nil) {
                message = platformViewModel.message
                htmlString = nil
            } else {
                message = nil
                htmlString = platformViewModel.detailHTML!
            }
            sceneTitle = viewModel.navigationBarTitle
        } else {
            message = Theme.detailAttributed(string: Localizations.CommandDetail.NothingSelected)
            htmlString = nil
            sceneTitle = ""
        }
        
        if let messageToShow = message {
            messageLabel.attributedText = messageToShow
            messageView.isHidden = false
            
            messageView.setNeedsLayout()
        } else {
            messageView.isHidden = true
        }
        
        if let htmlStringToShow = htmlString {
            webView.loadHTMLString(htmlStringToShow, baseURL: nil)
            
            // TODO: fix this terrible hack - show the webView after a delay, to avoid an annoying white flash
            // ideally, we would *unhide* the webView here - but WKWebView flashes if its visible while loading
            // https://feedbackassistant.apple.com/feedback/6605638
            webView.isHidden = true
        } else {
            webView.isHidden = true
        }
        
        title = sceneTitle
    }
    
    private func doConfigureFavourite() {
        if let viewModel = viewModel {
            let imageLarge = UIImage(imageLiteralResourceName: viewModel.favouriteButtonIconLarge)
            let imageSmall = UIImage(imageLiteralResourceName: viewModel.favouriteButtonIconSmall)
            let favouriteButton = UIBarButtonItem(image: imageLarge, landscapeImagePhone: imageSmall, style: .plain, target: self, action: #selector(DetailViewController.onFavouriteToggled))
            navigationItem.rightBarButtonItem = favouriteButton
        }
    }
    
    @objc private func onFavouriteToggled() {
        viewModel?.onFavouriteToggled()
        
        DispatchQueue.main.async {
            UISelectionFeedbackGenerator().selectionChanged()
        }
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

extension DetailViewController: DetailViewModelDelegate {
    func updateFavourite() {
        if viewIfLoaded == nil {
            return
        }
        
        DispatchQueue.main.async {
            self.doConfigureFavourite()
        }
    }
    
    func updateCommand() {
        if viewIfLoaded == nil {
            return
        }
        
        DispatchQueue.main.async {
            self.doConfigureCommand()
        }
    }
    
    func updatePlatformContent() {
        if viewIfLoaded == nil {
            return
        }
        
        DispatchQueue.main.async {
            self.doConfigurePlatformContent()
        }
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
    
    // TODO: fix this terrible hack - show the webView after a delay, to avoid an annoying white flash
    // https://feedbackassistant.apple.com/feedback/6605638
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(50)) {
            self.webView.isHidden = false
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
