//
//  LocationManager.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject{
    
    @Published var location : CLLocationCoordinate2D?
    var manager = CLLocationManager()
    
    func checkLocationAuthorization(){
        
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location restricted due to parental control")
        case .denied:
            print("Location Denied")
        case .authorizedAlways:
            print("Location authorizedAlways")
        case .authorizedWhenInUse:
            print("Location authorized when in use")
            location = manager.location?.coordinate
        @unknown default:
            print("Location Service disabled")
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
}
