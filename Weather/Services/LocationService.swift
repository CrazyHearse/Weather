//
//  LocationService.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import Foundation
import CoreLocation

struct Location {
    let lat: Double
    let lon: Double
}

protocol LocationServiceDelegate: AnyObject {
    func locationIsDisabled()
    func didUpdateLocation(location: Location)
    func didntUpdateLocation()
}

class LocationService: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationServiceDelegate?
    
    private let locationManager = CLLocationManager()
    private var location: Location?
    
    override init() {
        super.init()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() { 
        locationManager.requestLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.locationServicesEnabled() {
            lagWithSeconds(15) {
                if self.location == nil {
                    self.delegate?.didntUpdateLocation()
                }
            }
        } else {
            self.delegate?.locationIsDisabled()
        }
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue = locations.last {
            let location = Location(lat: locValue.coordinate.latitude, lon: locValue.coordinate.longitude)
            self.delegate?.didUpdateLocation(location: location)
            self.stopUpdatingLocation()
        }
    }
    
    
}
