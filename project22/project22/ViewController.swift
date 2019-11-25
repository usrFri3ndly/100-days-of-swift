//
//  ViewController.swift
//  project22
//
//  Created by Sc0tt on 24/11/2019.
//  Copyright © 2019 Sc0tt. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var distanceReading: UILabel!
    var locationManager: CLLocationManager?
    
    var displayAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create location request and push to user
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        //locationManager?.requestWhenInUseAuthorization()
        // location always required for this app to function correctly
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // check if device can monitor beacons
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                // check if device can detect range of a beacon
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        
        /* old code for ios <13
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        */
        
        // test beacon
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        //let beconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        let beconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        
        // monitor beacon and determine distrance
        locationManager?.startMonitoring(for: beconRegion)
        // locationManager?.startRangingBeacons(in: beconRegion)
        locationManager?.startRangingBeacons(satisfying: beconRegion.beaconIdentityConstraint)
    }
    
    // core location proximinity passed in by locationManager
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    // look for beacons in array
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
            
            // beacon detected alert
            if displayAlert == false {
                displayAlert = true
                let ac = UIAlertController(title: "Beacon Detected!", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
                present(ac, animated: true)
            }
        } else {
            update(distance: .unknown)
        }
    }
}

