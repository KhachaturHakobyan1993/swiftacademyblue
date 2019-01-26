//
//  ViewController.swift
//  Unit testing with XCTest
//
//  Created by Khachatur Hakobyan on 1/26/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var playData = PlayData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    
    // MARK: - Methods Setup -

    private func setup() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
    }
    
    @objc func searchTapped() {
        let alertVC = UIAlertController(title: "Filter…", message: nil, preferredStyle: .alert)
        alertVC.addTextField()
        
        alertVC.addAction(UIAlertAction(title: "Filter", style: .default) { [unowned self] _ in
            let userInput = alertVC.textFields?[0].text ?? "0"
            self.playData.applyUserFilter(userInput)
            self.tableView.reloadData()
        })
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertVC, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playData.filteredWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let word = self.playData.filteredWords[indexPath.row]
        cell.textLabel!.text = word
        cell.detailTextLabel!.text = "\(self.playData.wordCounts.count(for: word))"
        return cell
    }
}

