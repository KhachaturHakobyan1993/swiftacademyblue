//
//  ViewController.swift
//  Capital Cities
//
//  Created by Khachatur Hakobyan on 1/2/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import MapKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBarButtonItem()
        self.setupCapitalsAnnotations()
    }
    
    
    // MARK: - Methods Setup -
    
    private func setupBarButtonItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(ViewController.showAlertForMapType))
    }
    
    private func setupCapitalsAnnotations() {
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        self.mapView.addAnnotations([london, oslo, paris, rome, washington])
    }
    
    
    // MARK: - Methods -
    
    @objc private func showAlertForMapType() {
        let handler: (UIAlertAction) -> () = { action in
            switch action.title {
            case "standard":
                self.mapView.mapType = .standard
            case "satellite":
                self.mapView.mapType = .satellite
            case "hybrid":
                self.mapView.mapType = .hybrid
            case "satelliteFlyover":
                self.mapView.mapType = .satelliteFlyover
            case "hybridFlyover":
                self.mapView.mapType = .hybridFlyover
            case "mutedStandard":
                self.mapView.mapType = .mutedStandard
            default:
                break
            }
        }
        let alertVC = UIAlertController(title: "Choose Type of Map", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "standard", style: .default, handler: handler))
        alertVC.addAction(UIAlertAction(title: "satellite", style: .default, handler: handler))
        alertVC.addAction(UIAlertAction(title: "hybrid", style: .default, handler: handler))
        alertVC.addAction(UIAlertAction(title: "satelliteFlyover", style: .default, handler: handler))
        alertVC.addAction(UIAlertAction(title: "hybridFlyover", style: .default, handler: handler))
        alertVC.addAction(UIAlertAction(title: "mutedStandard", style: .default, handler: handler))
        alertVC.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}


// MARK: - MKMapViewDelegate -

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Capital else { return nil }
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Capital") as? MKPinAnnotationView else {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Capital")
            pinAnnotationView.canShowCallout = true
            let buttonInfo = UIButton(type: .detailDisclosure)
            pinAnnotationView.rightCalloutAccessoryView = buttonInfo
            pinAnnotationView.setLeftCalloutAccessoryView()
            return pinAnnotationView
        }
        annotationView.setLeftCalloutAccessoryView()
        annotationView.annotation = annotation
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        if control.tag == 77 {
            capital.isFavorite = !capital.isFavorite
            view.setLeftCalloutAccessoryView()
        } else {
            let placeName = capital.title
            let placeInfo = capital.info
            
            let alertVC = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}


// MARK: - MKAnnotationView -

extension MKAnnotationView {
    func setLeftCalloutAccessoryView() {
        guard let capital = self.annotation as? Capital else { return }
        let buttonFavorite = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        let img = capital.isFavorite ? #imageLiteral(resourceName: "imgFavorite1") : #imageLiteral(resourceName: "imgFavorite0")
        buttonFavorite.setBackgroundImage(img, for: .normal)
        buttonFavorite.setTitle("Favorite", for: .normal)
        buttonFavorite.tag = 77
        self.leftCalloutAccessoryView = buttonFavorite
        guard let pin = self as? MKPinAnnotationView else { return }
        pin.pinTintColor = (capital.isFavorite ? UIColor.green : UIColor.red)
    }
}

