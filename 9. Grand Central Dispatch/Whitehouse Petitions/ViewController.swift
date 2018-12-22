//
//  ViewController.swift
//  Grand Central Dispatch
//
//  Created by Khachatur Hakobyan on 12/19/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSelector(inBackground: #selector(ViewController.fethcPetitions), with: nil)
    }

    
    // MARK: - Methods -

    @objc func fethcPetitions() {
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        guard let url = URL(string: urlString),
            let data = try? Data(contentsOf: url) else {
                self.performSelector(onMainThread: #selector(ViewController.showError), with: nil, waitUntilDone: false)
                self.showError()
                return
        }
        self.parse(json: data)
    }
    
    func parse(json: Data) {
        let jsonDecoder = JSONDecoder()
        guard let jsonPetitions = try? jsonDecoder.decode(Petitions.self, from: json) else {
             self.performSelector(onMainThread: #selector(ViewController.showError), with: nil, waitUntilDone: false)
            return
        }
        self.petitions = jsonPetitions.results
        self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func showError() {
        let alertVC = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = self.petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    
    // MARK: - UITableViewDelegate -

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.detailItem = self.petitions[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
