//
//  Capital.swift
//  Capital Cities
//
//  Created by Khachatur Hakobyan on 1/2/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var isFavorite = false
    
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String ) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}




