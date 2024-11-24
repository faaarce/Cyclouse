//
//  LocationManagerDelegate.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManager(didUpdateAddress address: ShippingAddress)
    func locationManager(didFailWithError error: LocationError)
    func locationManager(didUpdateLocation location: CLLocation)
}
