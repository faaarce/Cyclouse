//
//  LocationManaging.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//
import MapKit
import Foundation
import CoreLocation

protocol LocationManaging {
  var delegate: LocationServiceDelegate? { get set }
  var currentLocation: CLLocation? { get }
  var authorizationStatus: CLAuthorizationStatus { get }
  
  func requestLocationPermission()
  func startUpdatingLocation()
  func stopUpdatingLocation()
  func reverseGeocodeLocation(_ location: CLLocation)
  func findNearbyPlaces(by query: String, in region: MKCoordinateRegion, completion: @escaping ([PlaceAnnotation]) -> Void)
}
