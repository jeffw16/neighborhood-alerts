//
//  Alert.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/21/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Alert {
    var id: String // UUID of alert location
    var displayName: String // what's displayed on the map
    
    var description: String
    var category: String
    var image: UIImage?
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var author: String


    
    init(id: String, displayName: String, description: String, category: String, image: UIImage?, latitude: CLLocationDegrees, longitude: CLLocationDegrees, author: String) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.category = category
        self.image = image ?? nil

        self.latitude = latitude
        self.longitude = longitude
        self.author = author
    }
}
