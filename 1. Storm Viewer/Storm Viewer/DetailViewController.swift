//
//  DetailViewController.swift
//  Storm Viewer
//
//  Created by Khachatur Hakobyan on 12/15/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    var selectedImage: String?
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.navigationController?.isNavigationBarHidden ?? false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.hidesBarsOnTap = false
    }
    
    
    // MARK: - Methods -
    
    private func setup() {
        self.title = "View Picture"
        self.navigationItem.largeTitleDisplayMode = .never
        if let imageToLoad = self.selectedImage {
            self.imageView.image = UIImage(named: imageToLoad)
            self.title = self.selectedImage
        }
    }
}
