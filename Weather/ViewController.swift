//
//  ViewController.swift
//  Weather
//
//  Created by Lukas Bimba on 7/3/20.
//  Copyright © 2020 Lukas Bimba. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var doubleTap: UITapGestureRecognizer!
    @IBOutlet var userLocationPress: UILongPressGestureRecognizer!
    
    var locationManager = CLLocationManager()
    var Longitude: Double?
    var Latitude: Double?
    var userLongitude: Double?
    var userLatitude: Double?
    var dataToBeSent: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.stopUpdatingLocation()
        
        let pressLocation = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        pressLocation.minimumPressDuration = 1.0
        
        // Double Tap
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gestureRecognizer:)))
        doubleTapGesture.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(doubleTapGesture)
        mapView.addGestureRecognizer(pressLocation)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            print("Need Location Request")
        } else if CLLocationManager.authorizationStatus() == .denied {
            print("User has denied request to location access")
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
            print("Location Access - Updating")
            
            self.userLongitude = locationManager.location?.coordinate.longitude
            self.userLatitude = locationManager.location?.coordinate.latitude
                
            print("printing the users location")
            print(userLongitude)
            print("user longitude")
            print(userLatitude)
            print("user Latitude")
        }
        
        setupUserTrackingButtonAndScaleView()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //dataToBeSent = locationData![key!] as? NSDictionary
        
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "MapWeatherPopUp") as? MapWeatherPopUP else { return }
        let height: CGFloat = 600
        let topCornerRadius: CGFloat = 35
        let presentDuration: Double = 0.5
        let dismissDuration: Double = 0.5
        
        popupVC.lat = Latitude
        popupVC.long = Longitude
        popupVC.height = height
        popupVC.topCornerRadius = topCornerRadius
        popupVC.presentDuration = presentDuration
        popupVC.dismissDuration = dismissDuration
        popupVC.shouldDismissInteractivelty = true
        present(popupVC, animated: true, completion: nil)
    }
    
    
    // Double tap action
    @objc func handleDoubleTap(gestureRecognizer:UIGestureRecognizer) {
        print("double tapped")
            var touchPoint = gestureRecognizer.location(in: mapView)
            var newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.removeAnnotations(mapView.annotations)
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks![0] as! CLPlacemark
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    annotation.title = pm.locality! + ", " +  pm.administrativeArea!
                    if let streetNumber = pm.subThoroughfare,
                        let streetName = pm.thoroughfare,
                        let city = pm.locality,
                        let state = pm.administrativeArea {
                        //self.addressLabel.text = "\(streetNumber) \(streetName), \(city) \(state)"
                    }
                    
                    self.mapView.addAnnotation(annotation)
                    self.Longitude = pm.location!.coordinate.longitude
                    self.Latitude = pm.location!.coordinate.latitude
                    self.userLongitude =  pm.location!.coordinate.longitude
                    self.userLatitude = pm.location!.coordinate.latitude
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
                //places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
            })
    }
    
    @objc func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            var touchPoint = gestureRecognizer.location(in: mapView)
            var newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            //mapView.removeAnnotations(mapView.annotations)
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks![0] as! CLPlacemark
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    annotation.title = pm.subThoroughfare! + ", " + pm.thoroughfare!
                    annotation.subtitle = pm.locality! + pm.administrativeArea!
                    if let streetNumber = pm.subThoroughfare,
                        let streetName = pm.thoroughfare,
                        let city = pm.locality,
                        let state = pm.administrativeArea {
                        //self.addressLabel.text = "\(streetNumber) \(streetName), \(city) \(state)"
                    }
                    
                    self.mapView.addAnnotation(annotation)
                    self.userLongitude = pm.location!.coordinate.longitude
                    self.userLatitude = pm.location!.coordinate.latitude
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
                //places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
            })
        } else if gestureRecognizer.numberOfTouches == 2 {
            print("double tapped")
        }
    }

    func setupUserTrackingButtonAndScaleView() {
        mapView.showsUserLocation = true
        
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
                                     button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                                     scale.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -30),
                                     scale.centerYAnchor.constraint(equalTo: button.centerYAnchor)])
        

    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
/*
extension ViewController: CustomerAddSearchCustomLocation {
    
    func dropPinZoomIn(placemark: MKMapItem) {
        //businessName.text = placemark.placemark.name
        if let streetNumber = placemark.placemark.subThoroughfare,
            let streetName = placemark.placemark.thoroughfare,
            let city = placemark.placemark.locality,
            let state = placemark.placemark.administrativeArea {
            addressLabel.text = "\(streetNumber) \(streetName), \(city) \(state)"
        }
        
        self.userLongitude = placemark.placemark.coordinate.longitude
        self.userLatitude = placemark.placemark.coordinate.latitude
        
        // cache the pin
        selectedPin = placemark.placemark
        // clear existing pins
        //mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.placemark.coordinate
        annotation.title = placemark.placemark.name
        if let city = placemark.placemark.locality,
            let state = placemark.placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
*/
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"")
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = btn
            return annotationView
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        print("doubletapped")
    }
}
