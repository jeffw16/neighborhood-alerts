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
import Firebase
import FirebaseFirestore
import FirebaseStorage

class Alert {
    var id: String // UUID of alert location
    var displayName: String // what's displayed on the map
    
    var description: String
    var category: String
    var image: String? // URL of the image, if it exists
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var authorName: String
    var authorEmail: String
    var created: Timestamp
    var upvotes: Int // number of upvotes (think Stack Overflow or Reddit)

    init(id: String, displayName: String, description: String, category: String, image: String?, latitude: CLLocationDegrees, longitude: CLLocationDegrees, authorName: String, authorEmail: String, created: Timestamp, upvotes: Int) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.category = category
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.created = created
        self.upvotes = upvotes
    }
    
    // Makes connection to Firebase Firestore and
    // loads information into the app
    // using async model to support Firebase async calls
    static func loadAlerts(_ completion: @escaping ([Alert]) -> ()) {
        var alertsToReturn: [Alert] = []
        
        let db = Firestore.firestore()
        let alertsRef = db.collection("alerts")
        let filteredRef = alertsRef.order(by: "created", descending: true).limit(to: 10)
        
        filteredRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
//                print(querySnapshot!.documents.count)
                for document in querySnapshot!.documents {
                    let id = document.documentID
                    let data = document.data()
                    let displayName = data["displayName"] as! String
                    let description = data["description"] as! String
                    let authorName = data["authorName"] as! String
                    let authorEmail = data["authorEmail"] as! String
                    let category = data["category"] as! String
                    let created = data["created"] as! Timestamp
                    let imageStringOpt = data["image"] as? String
                    let location = data["location"] as! GeoPoint
                    let upvotes = data["upvotes"] as? Int
                    
                    let alertToAdd = Alert(id: id,
                                           displayName: displayName,
                                           description: description,
                                           category: category,
                                           image: imageStringOpt,
                                           latitude: CLLocationDegrees(location.latitude),
                                           longitude: CLLocationDegrees(location.longitude),
                                           authorName: authorName,
                                           authorEmail: authorEmail,
                                           created: created,
                                           upvotes: upvotes ?? 0)
                    alertsToReturn.append(alertToAdd)
                }
            }
            completion(alertsToReturn)
        }
    }
}
