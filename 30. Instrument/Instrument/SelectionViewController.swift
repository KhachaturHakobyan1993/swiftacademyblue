//
//  SelectionViewController.swift
//  Instrument
//
//  Created by Khachatur Hakobyan on 1/8/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
    var imageFileNames = [String]()
    var viewControllers = [(UIViewController, Int)]() // create a cache of the detail view controllers for faster loading
    var dirty = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.getImages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadIfNeeded()
    }
    
    
    // MARK: - Methods Setup -
    
    private func setup() {
        self.title = "Reactionist"
        self.tableView.rowHeight = 90
        self.tableView.separatorStyle = .none
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    private func getImages() {
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath!) else { return }
        for oneItem in items {
            guard oneItem.range(of: "Large") != nil else { continue }
            self.imageFileNames.append(oneItem)
        }
    }
    
    
    // MARK: - Methods -
    
    private func showDetails(indexPath: IndexPath) {
        let index = indexPath.row % self.imageFileNames.count
        guard let cacheDetailVC = self.viewControllers.filter({ $0.1 == index }).first?.0 else {
            let detailVC = ImageViewController()
            detailVC.imageName = self.imageFileNames[index]
            detailVC.owner = self
            
            // mark us as not needing a counter reload when we return
            self.dirty = false
            
            // add to our view controller cache and show
            self.viewControllers.append((detailVC, index))
            self.navigationController!.pushViewController(detailVC, animated: true)
            return
        }
        self.navigationController!.pushViewController(cacheDetailVC, animated: true)
    }
    
    private func reloadIfNeeded() {
        guard self.dirty else { return }
        self.tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource & UITableViewDelegate -
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageFileNames.count * 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        

        let currentImage = self.imageFileNames[indexPath.row % self.imageFileNames.count]
        let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
        let path = Bundle.main.path(forResource: imageRootName, ofType: nil)!
        let original = UIImage(contentsOfFile: path)!
        
        let renderRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 90, height: 90))

        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
        
        let imgRounded = renderer.image { context in
//            context.cgContext.setShadow(offset: CGSize.zero, blur: 200, color: UIColor.black.cgColor)
//            context.cgContext.fillEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
//            context.cgContext.setShadow(offset: CGSize.zero, blur: 0, color: nil)

            context.cgContext.addEllipse(in: renderRect)
            context.cgContext.clip()
            
            original.draw(in: renderRect)
        }
        
        cell.imageView?.image = imgRounded
        
        
        // give the images a nice shadow to make them look a bit more dramatic
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        cell.imageView?.layer.shadowRadius = 10
        cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 90, height: 90)).cgPath

        // each image stores how often it's been tapped
        let defaults = UserDefaults.standard
        cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showDetails(indexPath: indexPath)
    }
}

