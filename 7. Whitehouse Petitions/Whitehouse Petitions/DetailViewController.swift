//
//  DetailViewController.swift
//  Whitehouse Petitions
//
//  Created by Khachatur Hakobyan on 12/19/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    
    override func loadView() {
        self.setupWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadHTML()
    }

    
    // MARK: - Methods -
    
    func setupWebView() {
        self.webView = WKWebView()
        self.view = self.webView
    }
    
    func loadHTML() {
        guard let detailItem = self.detailItem else { return }
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%;} </style>
        </head>
        <body>
        \(detailItem.body)
        </body>
        </html>
        """
        self.webView.loadHTMLString(html, baseURL: nil)
    }

}
