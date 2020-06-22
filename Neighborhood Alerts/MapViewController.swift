//
//  MapViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let resultRadius = 40233.6 // 25 miles converted to meters
    
    let locationManager = CLLocationManager()
    
    var annotationsOnMap: [MKAnnotation] = []
    
    // amount of zoom, specified in meters
    let zoomLevel: Int = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestNotificationAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLocationServices()
        
        if locationManager.location != nil {
            let region = MKCoordinateRegion(
                center: locationManager.location!.coordinate,
                latitudinalMeters: CLLocationDistance(exactly: zoomLevel)!,
                longitudinalMeters: CLLocationDistance(exactly: zoomLevel)!)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            
            Alert.loadAlerts() { alertsToAdd in
                // adding alerts
                for alert in alertsToAdd {
                    let locationObject = CLLocation(latitude: alert.latitude, longitude: alert.longitude)
                    
                    if self.locationManager.location!.distance(from: locationObject) < self.resultRadius {
                        let pointAnnotation = MKPointAnnotation()
                        pointAnnotation.title = alert.displayName
                        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
                        
                        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: alert.id)
                        
                        self.annotationsOnMap.append(pinAnnotationView.annotation!)
                    }
                }
                
                self.mapView.addAnnotations(self.annotationsOnMap)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // let's remove all of the annotations from the map and
        // refresh them to appear when the map view reappears
        self.mapView.removeAnnotations(self.annotationsOnMap)
        self.annotationsOnMap = []
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            let alertController = UIAlertController(
                title: "Location services off",
                message: "In order to use Neighborhood Alerts, you need to turn location services on in Settings.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func checkLocationAuthorization() {
      switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            mapView.showsUserLocation = true
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            mapView.showsUserLocation = true
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            mapView.showsUserLocation = true
        case .restricted: // Show an alert letting them know what’s up
            let alertController = UIAlertController(
                title: "Location services off",
                message: "In order to use Neighborhood Alerts, you need to turn location services on in Settings.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            present(alertController, animated: true, completion: nil)
        case .denied: // Show alert telling users how to turn on permissions
            let alertController = UIAlertController(
                title: "Location services off",
                message: "In order to use Neighborhood Alerts, you need to turn location services on in Settings.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            present(alertController, animated: true, completion: nil)
        @unknown default:
            fatalError()
        }
    }
}

