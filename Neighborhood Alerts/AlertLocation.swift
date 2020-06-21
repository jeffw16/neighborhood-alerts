//
//  AlertLocation.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct AlertLocation {
    var id: String // GUID of alert location
    var displayName: String // what's displayed on the map
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
}
