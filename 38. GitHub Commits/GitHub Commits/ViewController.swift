//
//  ViewController.swift
//  GitHub Commits
//
//  Created by Khachatur Hakobyan on 1/24/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import CoreData
import UIKit

class ViewController: UITableViewController {
    var fetchedResultsController: NSFetchedResultsController<Commit>!
    var container: NSPersistentContainer!
    var commitPredicate: NSPredicate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.loadNSPersistentContainer()
        self.performSelector(inBackground: #selector(ViewController.fetchCommits), with: nil)
        self.loadSavedData()
    }
    
    
    // MARK: - Methods -
    
    private func setup() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(ViewController.changeFilter))
    }
    
    @objc private func changeFilter() {
        let alertVC = UIAlertController(title: "Filter commits…", message: nil, preferredStyle: .actionSheet)
        // 1
        alertVC.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        })
        
        // 2
        alertVC.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        })
        
        // 3
        alertVC.addAction(UIAlertAction(title: "Show only recent", style: .default) { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        })
        
        // 4
        alertVC.addAction(UIAlertAction(title: "Show only Durian commits", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        })
        
        // 5
        alertVC.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData()
        })
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertVC, animated: true)
    }
    
    private func loadNSPersistentContainer() {
        self.container = NSPersistentContainer(name: "GitHub Commits")
        self.container.loadPersistentStores { (storeDescription, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            guard let error = error else { return }
            debugPrint(error)
        }
    }
    
    private func saveContext() {
        guard self.container.viewContext.hasChanges else { return }
        do {
            try self.container.viewContext.save()
        } catch {
            debugPrint("An error occurred while saving: \(error)")
        }
    }
    
    @objc private func fetchCommits() {
        let newestCommitDate = self.getNewestCommitDate()
        guard let url = URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)"),
            let data = try? String(contentsOf: url) else { return }
        // give the data to SwiftyJSON to parse
        let jsonCommits = JSON(parseJSON: data)
        
        // read the commits back out
        let jsonCommitArray = jsonCommits.arrayValue
        
        debugPrint("Received \(jsonCommitArray.count) new commits.")
        
        DispatchQueue.main.async { [unowned self] in
            for jsonCommit in jsonCommitArray {
                // the following three lines are new
                let commit = Commit(context: self.container.viewContext)
                self.configure(commit: commit, usingJSON: jsonCommit)
            }
            
            self.saveContext()
            self.loadSavedData()
        }
    }
    
    private func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
        var commitAuthor: Author!
        
        // see if this author exists already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? self.container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                // we have this author already
                commit.author = authors[0]
            }
        }
        
        if commitAuthor == nil {
            // we didn't find a saved author - create a new one!
            let author = Author(context: self.container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        commit.author = commitAuthor
    }
    
    private func loadSavedData() {
        if self.fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "author.name", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            self.fetchedResultsController.delegate = self
        }
        
        self.fetchedResultsController.fetchRequest.predicate = self.commitPredicate
        
        do {
            try self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch {
            debugPrint("Fetch failed")
        }
    }
    
    
    private func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()
        
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        
        if let commits = try? self.container.viewContext.fetch(newest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1) as Date)
            }
        }
        
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    
    // MARK: - UITableViewDataSource & UITableViewDelegate -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sections![section].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        let commit = self.fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.detailItem = self.fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let commit = self.fetchedResultsController.object(at: indexPath)
        self.container.viewContext.delete(commit)
        self.saveContext()
    }
}


// MARK: - NSFetchedResultsControllerDelegate -

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.loadSavedData()
        default:
            break
        }
    }
}
