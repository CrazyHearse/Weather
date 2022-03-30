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
    
}
