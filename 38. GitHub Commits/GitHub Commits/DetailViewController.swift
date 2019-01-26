//
//  DetailViewController.swift
//  GitHub Commits
//
//  Created by Khachatur Hakobyan on 1/24/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var detailLabel: UILabel!
    var detailItem: Commit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let detail = self.detailItem else { return }
        self.detailLabel.text = detail.message
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)", style: .plain, target: self, action: #selector(DetailViewController.showAuthorCommits))
    }
    
    @objc func showAuthorCommits() {
        // this is your homework!
    }
}
