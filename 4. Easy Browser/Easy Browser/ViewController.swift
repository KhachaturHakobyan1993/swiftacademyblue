//
//  ViewController.swift
//  Easy Browser
//
//  Created by Khachatur Hakobyan on 12/17/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import WebKit


class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "hackingwithswift.com"]
    

    override func loadView() {
        self.setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBarButtonItems()
        self.setupWebView()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            self.updateProgressViewUI()
        }
    }
    
    // MARK: - Methods -
    
    func setupView() {
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        self.view = webView
    }

    func setupBarButtonItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(ViewController.openTapped))
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self.webView, action: #selector(self.webView.reload))
        self.progressView = UIProgressView(progressViewStyle: .bar)
        self.progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: self.progressView)
        self.toolbarItems = [progressButton, spacerButton, refreshButton]
        self.navigationController?.isToolbarHidden = false
    }
    
    func setupWebView() {
        let url = URL(string: "https://www.hackingwithswift.com")!
        self.webView.load(URLRequest(url: url))
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    func updateProgressViewUI() {
        self.progressView.progress = Float(self.webView.estimatedProgress)
    }
    
    @objc func openTapped() {
        let alertVC = UIAlertController(title: "Open page…", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "apple.com", style: .default, handler: self.openPage))
        alertVC.addAction(UIAlertAction(title: "hackingwithswift.com", style: .default, handler: self.openPage))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(alertVC, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)!
        self.webView.load(URLRequest(url: url))
    }
    
    
    // MARK: - WKNavigationDelegate -
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = webView.title
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        decisionHandler(.cancel)
    }
}


