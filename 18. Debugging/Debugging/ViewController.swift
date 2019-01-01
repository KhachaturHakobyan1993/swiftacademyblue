//
//  ViewController.swift
//  Debugging
//
//  Created by Khachatur Hakobyan on 1/1/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I'm inside the viewDidLoad() method!")
        print(1, 2, 3, 4, 5, separator: "-")
        
        assert(1 == 1, "Maths failure!")
        
        for i in 1 ... 100 {
            print("Got number \(i)")
        }
    }
}

