//
//  ViewController.swift
//  SwiftSearcher
//
//  Created by Khachatur Hakobyan on 1/9/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices
import SafariServices
import UIKit

class ViewController: UITableViewController {
    var projects = [[String]]()
    var favorites = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.getProjects()
        self.getFavorites()
    }
    

    // MARK: - Methods Setup -
    
    private func setup() {
        self.title = "Swift Academy Blue"
        self.tableView.isEditing = false
        self.tableView.allowsSelectionDuringEditing = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ViewController.allowTableViewEditable))
    }
    
    func getProjects() {
        self.projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, FileManager, storyboards", "https://medium.com/@swiftacademyblue/swift-5-constants-and-variables-method-overrides-table-views-and-image-views-app-bundles-79dd15a79b72"])
        self.projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController", "https://medium.com/@swiftacademyblue/swift-5-interface-builder-auto-layout-outlets-2x-and-3x-images-asset-catalogs-integers-c5b60d63dae1"])
        self.projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL", "https://medium.com/@swiftacademyblue/swift-5-let-users-share-to-facebook-and-twitter-uibarbuttonitem-and-uiactivityviewcontroller-4ab3dc4c9f9b"])
        self.projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing", "https://medium.com/@swiftacademyblue/swift-5-wkwebview-loadview-delegation-classes-and-structs-url-urlrequest-uitoolbar-5728b1f30699"])
        self.projects.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange", "https://medium.com/@swiftacademyblue/swift-5-uitextchecker-unowned-how-to-reload-uitableview-data-and-how-to-insert-rows-45b1b2516c46"])
        self.projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code", "https://medium.com/@swiftacademyblue/swift-5-auto-layout-c35e237351ed"])
        self.projects.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController", "https://medium.com/@swiftacademyblue/swift-5-parsing-json-using-the-codable-protocol-loadhtmlstring-didfinishlaunchingwithoptions-5854e9eeaffd"])
        self.projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerated(), count, index(of:), property observers, range operators.", "https://medium.com/@swiftacademyblue/swift-5-addtarget-enumerated-index-of-joined-replacingoccurrences-5738e059ae9b"])
    }
    
    func getFavorites() {
        guard let savedFavorites = UserDefaults.standard.object(forKey: "favorites") as? [Int] else { return }
        self.favorites = savedFavorites
    }
    
    
    // MARK: - Methods -
    
    @objc func allowTableViewEditable() {
        self.tableView.isEditing = !self.tableView.isEditing
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
                               NSAttributedString.Key.foregroundColor: UIColor.purple]
        let subtitleAttibutes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttibutes)
        titleString.append(subtitleString)
        return titleString
    }
    
    func showTutorial(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: url, configuration: config)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    func index(item: Int) {
        let project = self.projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project[0]
        attributeSet.contentDescription = project[1]
        
        let item = CSSearchableItem(uniqueIdentifier: project[2], domainIdentifier: "com.medium", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            guard error == nil else {
                debugPrint("Indexing error: \(error!.localizedDescription)")
                return
            }
            debugPrint("Search item successfully indexed!")
        }
    }
    
    func deindex(item: Int) {
        let project = self.projects[item]
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [project[2]]) { error in
            guard error == nil else {
                debugPrint("Deindexing error: \(error!.localizedDescription)")
                return
            }
            debugPrint("Search item successfully removed!")
        }
    }
    
    
    // MARK: - UITableViewDataSource & UITableViewDelegate -

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let project = self.projects[indexPath.row]
        cell.textLabel?.attributedText = self.makeAttributedString(title: project[0], subtitle: project[1])
        cell.editingAccessoryType = self.favorites.contains(indexPath.row) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = self.projects[indexPath.row][2]
        self.showTutorial(urlString)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return self.favorites.contains(indexPath.row) ? .delete : .insert
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            self.favorites.append(indexPath.row)
            self.index(item: indexPath.row)
        case .delete:
            let index = self.favorites.firstIndex(of: indexPath.row)
            self.favorites.remove(at: index!)
            self.deindex(item: indexPath.row)
        default:
            break
        }
        UserDefaults.standard.set(self.favorites, forKey: "favorites")
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}

