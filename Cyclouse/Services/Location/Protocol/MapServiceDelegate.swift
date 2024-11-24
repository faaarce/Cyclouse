//
//  MapServiceDelegate.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import Foundation

// LocationServices/MapService.swift
protocol MapServiceDelegate: AnyObject {
    func mapService(didSelectPlace place: PlaceAnnotation)
    func mapService(didFailWithError error: LocationError)
}


