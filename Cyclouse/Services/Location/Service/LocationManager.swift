//
//  LocationMnager.swift
//  Cyclouse
//
//  Created by yoga arie on 15/11/24.
//
import MapKit
import Foundation
import CoreLocation

// LocationServices/LocationError.swift

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    weak var delegate: LocationManagerDelegate?
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            delegate?.locationManager(didFailWithError: .serviceDisabled)
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func getCurrentLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else {
                self?.delegate?.locationManager(didFailWithError: .addressNotFound)
                return
            }
            
            let address = ShippingAddress(
                street: placemark.thoroughfare ?? "",
                city: placemark.locality ?? "",
                state: placemark.administrativeArea ?? "",
                zipCode: placemark.postalCode ?? "",
                country: placemark.country ?? ""
            )
            
            self.delegate?.locationManager(didUpdateAddress: address)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.locationManager(didUpdateLocation: location)
        reverseGeocodeLocation(location)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError: LocationError
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            default:
                locationError = .unknown(error)
            }
        } else {
            locationError = .unknown(error)
        }
        delegate?.locationManager(didFailWithError: locationError)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            getCurrentLocation()
        case .denied, .restricted:
            delegate?.locationManager(didFailWithError: .serviceDisabled)
        default:
            break
        }
    }
}

// LocationServices/MapService.swift
protocol MapServiceDelegate: AnyObject {
    func mapService(didSelectPlace place: PlaceAnnotation)
    func mapService(didFailWithError error: LocationError)
}



// LocationServices/Models/MapViewState.swift
struct MapViewState {
    var region: MKCoordinateRegion
    var annotations: [MKAnnotation]
    var selectedAnnotation: MKAnnotation?
}
