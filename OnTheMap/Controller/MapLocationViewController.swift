//
//  MapLocationViewController.swift
//  OnTheMap
//
//  Created by Selasi Kudolo on 2020-04-15.
//  Copyright © 2020 Ewe Cat Productions. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class MapLocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let limit = 100
        let order = "updatedAt"
        Client.getStudentLocations(limit: limit, order: order) { response, error in
            if let error = error {
                self.showMessage(message: error.localizedDescription, title: "Connection Error")
                return
            }
            
            StudentLocationModel.locationsPast = response ?? [StudentInformation]()
            
            self.reloadData()
            self.mapView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.reloadInputViews()
        reloadData()
    }

    func reloadData() {
        mapView.removeAnnotations(mapView.annotations)
        
        for location in StudentLocationModel.locationsPast {
            let latitude   = CLLocationDegrees(location.latitude!)
            let longitude  = CLLocationDegrees(location.longitude!)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation        = MKPointAnnotation()
            annotation.title      = "\(location.firstName!) \(location.lastName!)"
            annotation.subtitle   = location.mediaURL
            annotation.coordinate = coordinate
            
            mapView.addAnnotation(annotation)
        }
    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if let pinView = pinView {
            pinView.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor   = MKPinAnnotationView.redPinColor()
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let url = view.annotation?.subtitle else { return }

        if url!.isValidURL {
            var validUrl = url!

            if !(validUrl.hasPrefix("http://") || validUrl.hasPrefix("https://")) {
                validUrl = "https://" + validUrl
            }

            if control == view.rightCalloutAccessoryView {
                let app = UIApplication.shared
                app.open(URL(string: validUrl)!, options: [:], completionHandler: nil)
            }

        } else {
            return
        }
    }
}
