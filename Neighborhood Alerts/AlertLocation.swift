//
//  AlertLocation.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class AlertLocation: NSObject, MKAnnotation {
    var id: String // GUID of alert location
    var displayName: String // what's displayed on the map
    var coordinate: CLLocationCoordinate2D
    var alert: Alert
    var title: String? {
        return alert.displayName
    }
    var subtitle: String? {
        return alert.category
    }
    
    init(alert: Alert) {
        self.id = alert.id
        self.displayName = alert.displayName
        self.coordinate = CLLocationCoordinate2DMake(alert.latitude, alert.longitude)
        self.alert = alert
    }
}
