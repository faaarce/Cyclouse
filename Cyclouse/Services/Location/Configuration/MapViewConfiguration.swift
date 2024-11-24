//
//  MapViewConfiguration.swift
//  Cyclouse
//
//  Created by yoga arie on 24/11/24.
//

import MapKit


// MARK: - Map Configuration Helper
struct MapViewConfiguration {
    static func configure(_ mapView: MKMapView) {
        let config = MKStandardMapConfiguration()
        config.elevationStyle = .realistic
        config.emphasisStyle = .default
        
        mapView.preferredConfiguration = config
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
    }
    
    static func createCamera(lookingAt center: CLLocationCoordinate2D, distance: CLLocationDistance = 1000, pitch: CGFloat = 60, heading: CLLocationDirection = 0) -> MKMapCamera {
        MKMapCamera(
            lookingAtCenter: center,
            fromDistance: distance,
            pitch: pitch,
            heading: heading
        )
    }
}
