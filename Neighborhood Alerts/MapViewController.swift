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
    
    let locationManager = CLLocationManager()
    
    // amount of zoom, specified in meters
    let zoomLevel: Int = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationServices()
        
        if locationManager.location != nil {
            let region = MKCoordinateRegion(
                center: locationManager.location!.coordinate,
                latitudinalMeters: CLLocationDistance(exactly: zoomLevel)!,
                longitudinalMeters: CLLocationDistance(exactly: zoomLevel)!)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            
            testFuncAddAlertAnnotationAtAmitsHouse()
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            let alertController = UIAlertController(
                title: "Location Services Off",
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
                title: "Location Services Off",
                message: "In order to use Neighborhood Alerts, you need to turn location services on in Settings.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            present(alertController, animated: true, completion: nil)
        case .denied: // Show alert telling users how to turn on permissions
            let alertController = UIAlertController(
                title: "Location Services Off",
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
    
    func testFuncAddAlertAnnotationAtAmitsHouse() {
        let amitsAddress: String = "607 Smartts Ln NE, Leesburg, VA"
        let localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = amitsAddress
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) in
            if localSearchResponse != nil {
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.title = "Bear Sighting"
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                
                let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
                
                self.mapView.addAnnotation(pinAnnotationView.annotation!)
            }
        }
    }


}

