//
//  MapViewState.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//
import MapKit
import Foundation

// LocationServices/Models/MapViewState.swift
struct MapViewState {
    var region: MKCoordinateRegion
    var annotations: [MKAnnotation]
    var selectedAnnotation: MKAnnotation?
}
