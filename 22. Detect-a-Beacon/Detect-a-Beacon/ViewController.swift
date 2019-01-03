//
//  ViewController.swift
//  Detect-a-Beacon
//
//  Created by Khachatur Hakobyan on 1/3/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController {
    @IBOutlet var distanceReadingLabel: UILabel!
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupLoactionManager()
    }
    
    
    // MARK: - Methods Setup -
    
    private func setup() {
        self.view.backgroundColor = UIColor.gray
    }
    
    private func setupLoactionManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestWhenInUseAuthorization()
    }
    
    
    // MARK: - Methods -
    
    private func startScanning() {
        let uuid = UUID(uuidString: "13726B0B-8199-493A-9397-320CC3FB1789")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        
        self.locationManager.startMonitoring(for: beaconRegion)
        self.locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    private func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) { [unowned self] in
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray
                self.distanceReadingLabel.text = "UNKNOWN"
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReadingLabel.text = "FAR"
            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReadingLabel.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReadingLabel.text = "RIGHT HERE"
            }
        }
    }
}


// MARK: - CLLocationManagerDelegate -

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            debugPrint("authorizedAlways")
            guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
                CLLocationManager.isRangingAvailable() else { return }
            self.startScanning()
            debugPrint("isRangingAvailable()")
        case .authorizedWhenInUse:
            debugPrint("authorizedWhenInUse")
        case .denied:
            debugPrint("denied")
        case .notDetermined:
            debugPrint("notDetermined")
        case .restricted:
            debugPrint("restricted")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        beacons.isEmpty ? self.update(distance: .unknown) :
            self.update(distance: beacons[0].proximity)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        debugPrint("rangingBeaconsDidFailFor")
        debugPrint("rangingBeaconsDidFailFor = ", (error as NSError).userInfo)
    }
}


