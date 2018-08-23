//
//  MYGps.swift
//  MysteryClient
//
//  Created by Developer on 09/08/18.
//  Copyright © 2018 Mebius. All rights reserved.
//

import Foundation
import CoreLocation

class MYGps: NSObject {
    static let shared = MYGps()
    public var currentGps = CLLocationCoordinate2D()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            start()        
        }
    }
    
    public func start() {
        locationManager.requestLocation()
    }
}

extension MYGps: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentGps = (manager.location?.coordinate)!
        print(currentGps)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location updates error \(error)")
    }
}
