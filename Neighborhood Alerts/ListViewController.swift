//
//  ListViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdateUpvoteDelegate, ResolveAlertDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var alertsList: [Alert] = []
    var selectedAlert: Alert?
    var refreshCtrl = UIRefreshControl()
    
    let detailedAlertSegueIdentifier: String = "DetailedAlertSegueIdentifier"
    let alertCellIdentifier: String = "AlertCellIdentifier"
    let locationManager = CLLocationManager()
    let resultRadii: [Int: Double] = [1: 1609.344,
                                      2: 3218.688,
                                      10: 16093.44,
                                      25: 40233.6,
                                      50: 80467.2] // miles converted to meters
    var resultRadius: Double = 40233.6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshCtrl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshCtrl.addTarget(self, action: #selector(loadAlerts), for: .valueChanged)
        tableView.addSubview(refreshCtrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAlerts()
    }
    
    @objc func loadAlerts() {
        let user = Auth.auth().currentUser
        guard let email = user?.email else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = appDelegate.persistentContainer.viewContext
        
        let chosenRadiusInMiles: Int = (CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "alertsRadius") ?? 25) as! Int
        
        self.resultRadius = resultRadii[chosenRadiusInMiles] ?? 40233.6
        
        Alert.loadAlerts() { alertsToAdd in
            let alertsSourceFromLocation: Bool = (CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "locationBasedAlerts") ?? true) as! Bool
            
            // refreshing alerts
            if self.locationManager.location != nil && alertsSourceFromLocation {
                self.filterAlertsWithinCurrentLocation(alerts: alertsToAdd) { alertsFiltered in
                    self.alertsList = alertsFiltered
                    // refresh table view to show new data
                    self.tableView.reloadData()
                }
            } else {
                self.filterAlertsWithinUserAddress(alerts: alertsToAdd) { alertsFiltered in
                    self.alertsList = alertsFiltered
                    // refresh table view to show new data
                    self.tableView.reloadData()
                }
            }
            self.refreshCtrl.endRefreshing()
        }
    }
    
    // filter alerts based on the current location provided by Location Services
    func filterAlertsWithinCurrentLocation(alerts: [Alert], completion: @escaping ([Alert]) -> ()) {
        if locationManager.location != nil {
            let homeAddressLocation = locationManager.location
            
            var filteredAlerts: [Alert] = []
            
            for alert in alerts {
                let locationObject = CLLocation(latitude: alert.latitude, longitude: alert.longitude)
                
                if homeAddressLocation!.distance(from: locationObject) < self.resultRadius {
                    filteredAlerts.append(alert)
                }
            }
            completion(filteredAlerts)
        } else {
            print("[Error] Cannot filter because could not locate coordinates of the user's provided address")
            completion(alerts)
        }
                   
    }
    
    // filter by the home address the user has stored
    func filterAlertsWithinUserAddress(alerts: [Alert], completion: @escaping ([Alert]) -> ()) {
        // get user info
        let user = Auth.auth().currentUser
        // populate email address on settings VC
        if let user = user {
            let email = user.email
            if email != nil {
                // got the email, let's grab the address
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(email!)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let homeAddress = document.data()!["homeAddress"] as! String
                        let localSearchRequest = MKLocalSearch.Request()
                        localSearchRequest.naturalLanguageQuery = homeAddress
                        let localSearch = MKLocalSearch(request: localSearchRequest)
                        localSearch.start { (localSearchResponse, error) in
                            if localSearchResponse != nil {
                                let homeAddressLocation = CLLocation(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                                
                                var filteredAlerts: [Alert] = []
                                
                                for alert in alerts {
                                    let locationObject = CLLocation(latitude: alert.latitude, longitude: alert.longitude)
                                    
                                    if homeAddressLocation.distance(from: locationObject) < self.resultRadius {
                                        filteredAlerts.append(alert)
                                    }
                                }
                                completion(filteredAlerts)
                            } else {
                                print("[Error] Cannot filter because could not locate coordinates of the user's provided address")
                                completion(alerts)
                            }
                        }
                    } else {
                        print("[Error] Cannot filter because could not retrive user profile from Firebase Firestore")
                        completion(alerts)
                    }
                }
            } else {
                // cannot filter, just return all alerts
                print("[Error] Cannot filter because could not retrive email address")
            }
        } else {
            print("Unauthorized user")
            completion(alerts)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: alertCellIdentifier, for: indexPath) as! AlertTableViewCell
        
        let rowNum = indexPath.row
        
        cell.alertTitle.text = alertsList[rowNum].displayName
        cell.alertDescription.text = alertsList[rowNum].description
        cell.alertImage.image = UIImage(named: "appstore")
        
        if let alertImageUrl = alertsList[rowNum].image {
            // if file exists, download the image
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            var context = appDelegate.persistentContainer.viewContext
            
            let cachedImageDataOpt:Data? = CoreDataHandler.fetchCachedImageData(name: alertImageUrl, context: &context, deleteAll: false) as? Data
            
            if let cachedImageData = cachedImageDataOpt {
                cell.alertImage.image = UIImage(data: cachedImageData)
            }
            else {
                let imageRef = Storage.storage().reference().child(alertImageUrl)
                
                imageRef.getData(maxSize: 10 * 1024 * 1024) {
                    (data, error) in
                    
                    cell.loadIcon.stopAnimating()
                    
                    if error == nil {
                        // got the image, set it
                        cell.alertImage.image = UIImage(data: data!)
                        CoreDataHandler.storeCachedImageData(name: alertImageUrl, data: data!, context: &context)
                    } else {
                        print(error!)
                    }
                }
            }
        } else {
            // if there's no image, don't add a loading icon
            cell.loadIcon.stopAnimating()
        }
        
//        cell.textLabel?.text = alertsList[rowNum].displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedAlert = alertsList[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    func updateUpvote(_ newCount: Int) {
        if let selectedAlert = selectedAlert {
            selectedAlert.upvotes = newCount
        }
    }
    
    func resolveAlert() {
        if let selectedAlert = selectedAlert {
            selectedAlert.resolved = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailedAlertSegueIdentifier {
            let nextVC = segue.destination as! DetailedAlertViewController
            
            let alertIndex:Int = tableView.indexPathForSelectedRow?.row ?? 0
            
            nextVC.alertTitle = alertsList[alertIndex].displayName
            nextVC.alertDescription = alertsList[alertIndex].description
            nextVC.alertImageUrl = alertsList[alertIndex].image
            nextVC.alertAuthorName = alertsList[alertIndex].authorName
            nextVC.alertCategory = alertsList[alertIndex].category
            nextVC.alertUpvotes = alertsList[alertIndex].upvotes
            nextVC.alertId = alertsList[alertIndex].id
            nextVC.originVC = self
        }
    }



}

