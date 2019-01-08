//
//  ViewController.swift
//  Multibrowser
//
//  Created by Khachatur Hakobyan on 1/8/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import WebKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var addressBarTextField: UITextField!
    @IBOutlet var stackView: UIStackView!
    weak var activeWebView: WKWebView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDefaultTitle()
        self.setupBarButtons()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.stackView.axis = self.traitCollection.horizontalSizeClass == .compact ? .vertical : .horizontal
    }
    
    
    // MARK: - Methods Setup -

    private func setupDefaultTitle() {
        self.title = "Multibrowser"
    }
    
    private func setupBarButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.addWebView))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ViewController.deleteWebView))
        self.navigationItem.rightBarButtonItems = [deleteButton, addButton]
    }
    
    
    // MARK: - Methods -
    
    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.layer.borderColor = UIColor.blue.cgColor
        self.selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        let array = ["https://www.apple.com", "https://medium.com", "https://medium.com/@swiftacademyblue", "https://www.bbc.co.uk/sport"]
        let url = URL(string: array.randomElement()!)!
        webView.load(URLRequest(url: url))
        self.stackView.addArrangedSubview(webView)
    }
    
    @objc func deleteWebView() {
        guard let webView = self.activeWebView,
            let index = self.stackView.arrangedSubviews.index(of: webView) else { return }
        self.stackView.removeArrangedSubview(webView)
        webView.removeFromSuperview()
        
        guard self.stackView.arrangedSubviews.count != 0 else {
            self.addressBarTextField.text = ""
            self.addressBarTextField.placeholder = "Write URL With https://"
            self.setupDefaultTitle()
            return
        }
        
        var currentIndex = Int(index)
        
        if currentIndex == self.stackView.arrangedSubviews.count {
            currentIndex = stackView.arrangedSubviews.count - 1
        }
        
        if let newSelectedWebView = self.stackView.arrangedSubviews[currentIndex] as? WKWebView {
            self.selectWebView(newSelectedWebView)
        }
    }
    
    @objc func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        guard let selectedWebView = recognizer.view as? WKWebView else { return }
        self.selectWebView(selectedWebView)
    }
    
    func selectWebView(_ webView: WKWebView) {
        for view in self.stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        self.activeWebView = webView
        webView.layer.borderWidth = 3
        self.updateUI(for: webView)
    }
    
    func updateUI(for webView: WKWebView) {
        self.title = webView.title
        self.addressBarTextField.text = webView.url?.absoluteString ?? ""
    }
}


// MARK: - WKNavigationDelegate -

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard webView == self.activeWebView else { return }
        self.updateUI(for: webView)
    }
}


// MARK: - UITextFieldDelegate -

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        defer { textField.resignFirstResponder() }
        guard let webView = self.activeWebView,
            var address = self.addressBarTextField.text else { return true }
        if !address.hasPrefix("http://") && !address.hasPrefix("http://") {
            address = "https://" + address
        }
        guard let url = URL(string: address) else { return true }
        webView.load(URLRequest(url: url))
        return true
    }
}


// MARK: - UIGestureRecognizerDelegate -

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
