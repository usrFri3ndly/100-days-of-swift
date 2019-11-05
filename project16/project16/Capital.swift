//
//  Capital.swift
//  project16
//
//  Created by Sc0tt on 04/11/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var wiki: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, wiki: String) {
        self.title = title
        self.coordinate = coordinate
        self.wiki = wiki
    }
}
