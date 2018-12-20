//
//  ViewController.swift
//  Storm Viewer
//
//  Created by Khachatur Hakobyan on 12/15/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    private var pictures = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.fetchPictures()
    }
    
    
    // MARK: - Methods -
    
    private func setup() {
        self.title = "Storm Viewer"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func fetchPictures() {
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fileManager.contentsOfDirectory(atPath: path)
        for oneItem in items {
            if oneItem.hasPrefix("nssl") {
                self.pictures.append(oneItem)
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource & UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = self.pictures[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DatailViewController") as? DetailViewController {
            detailVC.selectedImage = self.pictures[indexPath.row]
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

