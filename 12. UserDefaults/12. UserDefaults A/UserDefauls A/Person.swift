//
//  Person.swift
//  UserDefaults A
//
//  Created by Khachatur Hakobyan on 12/21/18.
//  Copyright © 2018 Khachatur Hakobyan. All rights reserved.
//

import UIKit

class Person: NSObject, NSCoding {
    var name: String
    var image: String
    
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    
    // MARK: - NSCoding -
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.image, forKey: "image")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.image = aDecoder.decodeObject(forKey: "image") as! String
    }
}
