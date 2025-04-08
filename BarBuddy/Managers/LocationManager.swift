//
//  LocationManager.swift
//  BarBuddy
//
//  Created by Andrew Betancourt on 3/26/25.
//

import CoreLocation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    @ObservationIgnored let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var isAuthorized = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        startLocationServices()
    }
    func startLocationServices() {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            isAuthorized = true
        } else {
            isAuthorized = false
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // TODO: Handle location settings properly
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            isAuthorized = false
        case .restricted:
            print("Location services restricted")
        case .denied:
            print("Location services denied")
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
        @unknown default:
            break
        }
    }
}
