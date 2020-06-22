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
import FirebaseFirestore

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let resultRadius = 40233.6 // 25 miles converted to meters
    let mapToDetailedAlertViewSegueIdentifier: String = "MapToDetailedAlertViewSegueIdentifier"
    
    let locationManager = CLLocationManager()
    
    var annotationsOnMap: [MKAnnotation] = []
    var selectedAlertLoc: AlertLocation?
    
    // amount of zoom, specified in meters
    let zoomLevel: Int = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        requestNotificationAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.selectedAlertLoc = nil
        
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
//                        let pointAnnotation = MKPointAnnotation()
                        let pointAnnotation = AlertLocation(alert: alert)
//                        pointAnnotation.title = alert.displayName
//                        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
                        
//                        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: alert.id)
                        
//                        self.annotationsOnMap.append(pinAnnotationView.annotation!)
                        self.annotationsOnMap.append(pointAnnotation)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? AlertLocation else { return nil }
        
        let identifier = annotation.id
        var view: MKMarkerAnnotationView
        

        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print("Annotation selected")
//        let alertId: String = view.reuseIdentifier ?? "invalidAlertId"
//        self.selectedAlertId = alertId
//        view.setSelected(false, animated: true)
//        self.performSegue(withIdentifier: mapToDetailedAlertViewSegueIdentifier, sender: self)
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let alertLoc = view.annotation as? AlertLocation else { return }
        self.selectedAlertLoc = alertLoc
        self.performSegue(withIdentifier: mapToDetailedAlertViewSegueIdentifier, sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == mapToDetailedAlertViewSegueIdentifier,
            let destination = segue.destination as? DetailedAlertViewController {
            destination.alertTitle = selectedAlertLoc?.displayName
            destination.alertDescription = selectedAlertLoc?.alert.description
            destination.alertImage = selectedAlertLoc?.alert.image
            destination.alertAuthorName = selectedAlertLoc?.alert.authorName
        }
    }
}
