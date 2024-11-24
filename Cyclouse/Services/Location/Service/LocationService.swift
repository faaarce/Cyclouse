//
//  LocationService.swift
//  Cyclouse
//
//  Created by yoga arie on 16/11/24.
//

import Foundation
import CoreLocation
import Combine
import MapKit

protocol LocationServiceDelegate: AnyObject {
  func didUpdateAddress(_ address: ShippingAddress)
  func didFailWithError(_ error: Error)
}


final class LocationService: NSObject, LocationManaging {
  // MARK: - Properties
    weak var delegate: LocationServiceDelegate?
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    var currentLocation: CLLocation? {
        locationManager.location
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                self?.delegate?.didFailWithError(error)
                return
            }
            
            guard let placemark = placemarks?.first else {
                self?.delegate?.didFailWithError(NSError(domain: "LocationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No address found"]))
                return
            }
            
            let address = ShippingAddress(
                street: placemark.thoroughfare ?? "",
                city: placemark.locality ?? "",
                state: placemark.administrativeArea ?? "",
                zipCode: placemark.postalCode ?? "",
                country: placemark.country ?? ""
            )
            
            self?.delegate?.didUpdateAddress(address)
        }
    }
    
    func findNearbyPlaces(by query: String, in region: MKCoordinateRegion, completion: @escaping ([PlaceAnnotation]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                completion([])
                return
            }
            
            let places = response.mapItems.map(PlaceAnnotation.init)
            completion(places)
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     
      locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            delegate?.didFailWithError(NSError(domain: "LocationService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Location services are disabled"]))
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}
