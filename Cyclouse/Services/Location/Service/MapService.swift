//
//  MapService.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//
import MapKit
import Foundation

class MapService: NSObject {
    static let shared = MapService()
    
    weak var delegate: MapServiceDelegate?
    
    func searchPlace(query: String, region: MKCoordinateRegion) async throws -> [PlaceAnnotation] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems.map(PlaceAnnotation.init)
    }
    
    func get3DCamera(for coordinate: CLLocationCoordinate2D,
                    distance: CLLocationDistance = 1000,
                    pitch: CGFloat = 60,
                    heading: CLLocationDirection = 45) -> MKMapCamera {
        return MKMapCamera(
            lookingAtCenter: coordinate,
            fromDistance: distance,
            pitch: pitch,
            heading: heading
        )
    }
}
