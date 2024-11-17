//
//  MapViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 30/10/24.
//
import UIKit
import MapKit
import CoreLocation
import Combine

// MARK: - MapViewController
class MapViewController: BaseViewController {

    // MARK: - Properties
    weak var delegate: AddressUpdateDelegate?
 
    private let checkoutService: CheckoutService
    private let locationManager = CLLocationManager()
    private var selectedAddress: ShippingAddress?
    private var places: [PlaceAnnotation] = []
    private var searchCompleter: MKLocalSearchCompleter?
    private var searchSuggestions: [MKLocalSearchCompletion] = []

    // Add search bar and suggestions table
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search places..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
        return searchBar
    }()

    private let suggestionsTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        table.layer.cornerRadius = 10
        table.isHidden = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // Add current location button
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - UI Components
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false

        // Create and apply configuration
        let config = MKStandardMapConfiguration()
        config.elevationStyle = .realistic  // Enable 3D terrain
        config.emphasisStyle = .default
        map.preferredConfiguration = config

        // Basic map features
        map.showsUserLocation = true
        map.showsCompass = true
        map.showsScale = true

        // 3D features
        map.showsBuildings = true
        map.isPitchEnabled = true  // Enables tilting for 3D view
        map.isRotateEnabled = true // Enables rotation for 3D view

        return map
    }()

    // 3D Buttons
    private lazy var threeDButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "view.3d"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var rotateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "rotate.3d"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization
    init(checkoutService: CheckoutService = CheckoutService()) {
        self.checkoutService = checkoutService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchCompleter()
        configureLocationServices()
        setupMapView()
        setup3DFeatures()
    }

    // MARK: - Setup Methods
    override func setupViews() {
        super.setupViews()
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(suggestionsTableView)
        view.addSubview(currentLocationButton)
        view.addSubview(threeDButton)
        view.addSubview(rotateButton)

        // Bring subviews to front
        view.bringSubviewToFront(searchBar)
        view.bringSubviewToFront(suggestionsTableView)
        view.bringSubviewToFront(currentLocationButton)
        view.bringSubviewToFront(threeDButton)
        view.bringSubviewToFront(rotateButton)

        searchBar.delegate = self
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")

        currentLocationButton.addTarget(self, action: #selector(currentLocationTapped), for: .touchUpInside)
        threeDButton.addTarget(self, action: #selector(toggle3DView), for: .touchUpInside)
        rotateButton.addTarget(self, action: #selector(rotateMapView), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            // MapView constraints
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Search Bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Suggestions Table View
            suggestionsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            suggestionsTableView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            suggestionsTableView.heightAnchor.constraint(equalToConstant: 200),

            // Current Location Button
            currentLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            currentLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 50),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 50),

            // 3D Button
            threeDButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            threeDButton.bottomAnchor.constraint(equalTo: currentLocationButton.topAnchor, constant: -16),
            threeDButton.widthAnchor.constraint(equalToConstant: 50),
            threeDButton.heightAnchor.constraint(equalToConstant: 50),

            // Rotate Button
            rotateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            rotateButton.bottomAnchor.constraint(equalTo: threeDButton.topAnchor, constant: -16),
            rotateButton.widthAnchor.constraint(equalToConstant: 50),
            rotateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    override func bindViewModel() {
        super.bindViewModel()
        // Bind any view models here if necessary
    }

    private func setupSearchCompleter() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        searchCompleter?.resultTypes = .address
    }

    // MARK: - 3D Map Features
    private func setup3DFeatures() {
        // Rotation gesture
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        mapView.addGestureRecognizer(rotationGesture)
    }

    @objc private func toggle3DView() {
        // Get current center
        let center = mapView.centerCoordinate

        // Create 3D camera
        let camera = MKMapCamera(
            lookingAtCenter: center,
            fromDistance: 1000, // Meters from the ground
            pitch: mapView.camera.pitch == 0 ? 60 : 0, // Toggle between 2D and 3D
            heading: mapView.camera.heading
        )

        // Animate camera change
        UIView.animate(withDuration: 0.5) {
            self.mapView.setCamera(camera, animated: true)
        }
    }

    @objc private func rotateMapView() {
        let camera = mapView.camera
        camera.heading += 45 // Rotate 45 degrees

        UIView.animate(withDuration: 0.3) {
            self.mapView.setCamera(camera, animated: true)
        }
    }

    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed {
            let camera = mapView.camera
            camera.heading += gesture.rotation * 180 / .pi
            mapView.setCamera(camera, animated: false)
            gesture.rotation = 0
        }
    }

    @objc private func currentLocationTapped() {
        locationManager.requestLocation()
        if let location = locationManager.location {
            // Create 3D camera for current location
            let camera = MKMapCamera(
                lookingAtCenter: location.coordinate,
                fromDistance: 1000,
                pitch: 60,
                heading: 0
            )

            // Animate to new position
            UIView.animate(withDuration: 0.5) {
                self.mapView.setCamera(camera, animated: true)
            }
        }
    }

    private func findNearbyPlace(by query: String) {
        mapView.removeAnnotations(mapView.annotations)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self,
                  let response = response,
                  error == nil else { return }

            self.places = response.mapItems.map(PlaceAnnotation.init)
            self.places.forEach { place in
                self.mapView.addAnnotation(place)
            }

            // Show places in 3D
            if let firstPlace = self.places.first {
                let camera = MKMapCamera(
                    lookingAtCenter: firstPlace.coordinate,
                    fromDistance: 1000,
                    pitch: 60,
                    heading: 45
                )
                self.mapView.setCamera(camera, animated: true)
            }
        }
    }

    private func showAllAnnotations() {
        let annotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        if annotations.count > 0 {
            mapView.showAnnotations(annotations, animated: true)
        }
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        if #available(iOS 17.0, *) {
            mapView.showsBuildings = true
            let configuration = MKStandardMapConfiguration()
            configuration.emphasisStyle = .default
            mapView.preferredConfiguration = configuration
        }
    }

    // MARK: - Location Services
    private func configureLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationServicesAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    // MARK: - Map Interactions
    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)

        // Add new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Selected Location"
        mapView.addAnnotation(annotation)

        // Reverse geocode the location
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        reverseGeocodeLocation(location)
    }

    private func reverseGeocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else {
              self?.showErrorAlert(message: "Unable to find address")
                return
            }

            // Create address components
            var addressComponents: [String] = []

            if let street = placemark.thoroughfare {
                addressComponents.append(street)
            }
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            }
            if let city = placemark.locality {
                addressComponents.append(city)
            }
            if let state = placemark.administrativeArea {
                addressComponents.append(state)
            }
            if let postalCode = placemark.postalCode {
                addressComponents.append(postalCode)
            }
            if let country = placemark.country {
                addressComponents.append(country)
            }

            let addressString = addressComponents.joined(separator: ", ")

            // Store the address for later use
            self.selectedAddress = ShippingAddress(
                street: placemark.thoroughfare ?? "",
                city: placemark.locality ?? "",
                state: placemark.administrativeArea ?? "",
                zipCode: placemark.postalCode ?? "",
                country: placemark.country ?? ""
            )

            // Show alert to confirm selection
            self.showAddressConfirmationAlert(address: addressString)
        }
    }

    private func showAddressConfirmationAlert(address: String) {
      /*
        let alert = UIAlertController(
            title: "Confirm Location",
            message: "Do you want to use this location?\n\(address)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            self?.confirmLocation()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)*/
      MessageAlert.showConfirmation(title: "Confirm Location", message: "Do you want to use this location?\n\(address)", confirmTitle: "Confirm", cancelTitle: "Cancel") {
        self.confirmLocation()
      }
    }

    private func confirmLocation() {
        guard let selectedAddress = selectedAddress else { return }

        let formattedAddress = [
            selectedAddress.street,
            selectedAddress.city,
            selectedAddress.state,
            selectedAddress.zipCode,
            selectedAddress.country
        ].filter { !$0.isEmpty }.joined(separator: ", ")

        delegate?.didUpdateAddress(formattedAddress)
        dismiss(animated: true)
    }

    // MARK: - Alert Handlers
    private func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message)
    }

    private func showLocationServicesAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services in Settings to use this feature.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Only zoom to user location if we haven't set a delivery location yet
        if mapView.annotations.isEmpty {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            mapView.setRegion(region, animated: true)
        }

        // Stop updating location since we don't need continuous updates
        locationManager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showLocationServicesAlert()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle the error appropriately
        print("Location error: \(error.localizedDescription)")

        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                showLocationServicesAlert()
            case .locationUnknown:
                showErrorAlert(message: "Unable to determine your location. Please try again.")
            default:
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension MapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            suggestionsTableView.isHidden = true
        } else {
            searchCompleter?.queryFragment = searchText
            suggestionsTableView.isHidden = false
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        suggestionsTableView.isHidden = true
        if let query = searchBar.text, !query.isEmpty {
            findNearbyPlace(by: query)
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension MapViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchSuggestions = completer.results
        suggestionsTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return searchSuggestions.count
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
         let suggestion = searchSuggestions[indexPath.row]
         cell.textLabel?.text = suggestion.title
         cell.detailTextLabel?.text = suggestion.subtitle
         return cell
     }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let suggestion = searchSuggestions[indexPath.row]
         searchBar.text = suggestion.title
         suggestionsTableView.isHidden = true
         searchBar.resignFirstResponder()
         findNearbyPlace(by: suggestion.title)
     }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        guard !(annotation is MKUserLocation) else { return }

        if let placeAnnotation = annotation as? PlaceAnnotation {
            // Reverse geocode to get detailed address
            let location = CLLocation(latitude: placeAnnotation.coordinate.latitude, longitude: placeAnnotation.coordinate.longitude)
            reverseGeocodeLocation(location)
        } else if let annotation = annotation as? MKPointAnnotation {
            // Reverse geocode for custom annotations
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            reverseGeocodeLocation(location)
        }
    }
}

// MARK: - Supporting Classes and Extensions

// AddressUpdateDelegate Protocol
protocol AddressUpdateDelegate: AnyObject {
    func didUpdateAddress(_ address: String)
}


// PlaceAnnotation Class
class PlaceAnnotation: MKPointAnnotation {
    let mapItem: MKMapItem
    let id = UUID()
    var isSelected: Bool = false

    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        super.init()
        self.coordinate = mapItem.placemark.coordinate
    }

    var name: String {
        mapItem.name ?? ""
    }

    var phone: String {
        mapItem.phoneNumber ?? ""
    }

    var address: String {
        "\(mapItem.placemark.subThoroughfare ?? "") \(mapItem.placemark.thoroughfare ?? "") \(mapItem.placemark.locality ?? "") \(mapItem.placemark.countryCode ?? "") "
    }

    var location: CLLocation {
        mapItem.placemark.location ?? CLLocation.default
    }
}

// CLLocation Extension
extension CLLocation {
    static var `default`: CLLocation {
        CLLocation(latitude: 36.063457, longitude: -95.880516)
    }
}


/*
 class MapViewController: UIViewController {
 
 var coordinator: MapViewCoordinator
 
 // MARK: - Properties
 private let mapView: MKMapView = {
 let map = MKMapView()
 map.translatesAutoresizingMaskIntoConstraints = false
 return map
 }()
 
 private let zoomStack: UIStackView = {
 let stack = UIStackView()
 stack.axis = .vertical
 stack.spacing = 8
 stack.translatesAutoresizingMaskIntoConstraints = false
 return stack
 }()
 
 private let zoomInButton: UIButton = {
 let button = UIButton()
 button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
 button.tintColor = .systemBlue
 button.backgroundColor = .white
 button.layer.cornerRadius = 20
 button.layer.shadowColor = UIColor.black.cgColor
 button.layer.shadowOffset = CGSize(width: 0, height: 2)
 button.layer.shadowRadius = 4
 button.layer.shadowOpacity = 0.2
 return button
 }()
 
 private let zoomOutButton: UIButton = {
 let button = UIButton()
 button.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
 button.tintColor = .systemBlue
 button.backgroundColor = .white
 button.layer.cornerRadius = 20
 button.layer.shadowColor = UIColor.black.cgColor
 button.layer.shadowOffset = CGSize(width: 0, height: 2)
 button.layer.shadowRadius = 4
 button.layer.shadowOpacity = 0.2
 return button
 }()
 
 private let recenterButton: UIButton = {
 let button = UIButton()
 button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
 button.tintColor = .systemBlue
 button.backgroundColor = .white
 button.layer.cornerRadius = 20
 button.layer.shadowColor = UIColor.black.cgColor
 button.layer.shadowOffset = CGSize(width: 0, height: 2)
 button.layer.shadowRadius = 4
 button.layer.shadowOpacity = 0.2
 return button
 }()
 
 private let locationManager = CLLocationManager()
 private var currentAnnotations: [MKAnnotation] = []
 
 // MARK: - Lifecycle
 override func viewDidLoad() {
 super.viewDidLoad()
 setupUI()
 configureLocationServices()
 setupMapFeatures()
 }
 
 init(coordinator: MapViewCoordinator) {
 self.coordinator = coordinator
 super.init(nibName: nil, bundle: nil)
 }
 
 required init?(coder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 // MARK: - UI Setup
 private func setupUI() {
 view.addSubview(mapView)
 setupCustomControls()
 
 NSLayoutConstraint.activate([
 mapView.topAnchor.constraint(equalTo: view.topAnchor),
 mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
 mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
 mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
 ])
 }
 
 private func setupCustomControls() {
 // Setup map type control
 let segmentedControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
 segmentedControl.selectedSegmentIndex = 0
 segmentedControl.translatesAutoresizingMaskIntoConstraints = false
 segmentedControl.backgroundColor = .white
 segmentedControl.layer.cornerRadius = 8
 segmentedControl.layer.shadowColor = UIColor.black.cgColor
 segmentedControl.layer.shadowOffset = CGSize(width: 0, height: 2)
 segmentedControl.layer.shadowRadius = 4
 segmentedControl.layer.shadowOpacity = 0.2
 segmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)
 
 // Setup zoom controls
 zoomStack.addArrangedSubview(zoomInButton)
 zoomStack.addArrangedSubview(zoomOutButton)
 zoomStack.addArrangedSubview(recenterButton)
 
 [zoomInButton, zoomOutButton, recenterButton].forEach { button in
 button.heightAnchor.constraint(equalToConstant: 40).isActive = true
 button.widthAnchor.constraint(equalToConstant: 40).isActive = true
 }
 
 view.addSubview(segmentedControl)
 view.addSubview(zoomStack)
 
 NSLayoutConstraint.activate([
 segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
 segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
 
 zoomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
 zoomStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
 ])
 
 // Add targets for zoom controls
 zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
 zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
 recenterButton.addTarget(self, action: #selector(recenterMap), for: .touchUpInside)
 }
 
 // MARK: - Location Services
 private func configureLocationServices() {
 locationManager.delegate = self
 locationManager.desiredAccuracy = kCLLocationAccuracyBest
 
 switch locationManager.authorizationStatus {
 case .notDetermined:
 locationManager.requestWhenInUseAuthorization()
 case .restricted, .denied:
 showLocationServicesAlert()
 case .authorizedWhenInUse, .authorizedAlways:
 locationManager.startUpdatingLocation()
 @unknown default:
 break
 }
 }
 
 // MARK: - Map Features
 private func setupMapFeatures() {
 mapView.delegate = self
 mapView.showsCompass = true
 mapView.showsUserLocation = true
 
 if #available(iOS 17.0, *) {
 mapView.showsBuildings = true
 let configuration = MKStandardMapConfiguration()
 configuration.emphasisStyle = .default
 mapView.preferredConfiguration = configuration
 }
 
 let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
 mapView.addGestureRecognizer(longPress)
 }
 
 // MARK: - Map Interactions
 @objc private func zoomIn() {
 var region = mapView.region
 region.span.latitudeDelta /= 2
 region.span.longitudeDelta /= 2
 mapView.setRegion(region, animated: true)
 }
 
 @objc private func zoomOut() {
 var region = mapView.region
 region.span.latitudeDelta *= 2
 region.span.longitudeDelta *= 2
 mapView.setRegion(region, animated: true)
 }
 
 @objc private func recenterMap() {
 if let userLocation = locationManager.location?.coordinate {
 let region = MKCoordinateRegion(
 center: userLocation,
 latitudinalMeters: 1000,
 longitudinalMeters: 1000
 )
 mapView.setRegion(region, animated: true)
 }
 }
 
 @objc private func mapTypeChanged(_ sender: UISegmentedControl) {
 switch sender.selectedSegmentIndex {
 case 0:
 mapView.mapType = .standard
 case 1:
 mapView.mapType = .satellite
 case 2:
 mapView.mapType = .hybrid
 default:
 break
 }
 }
 
 @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
 guard gesture.state == .began else { return }
 
 let point = gesture.location(in: mapView)
 let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
 
 // Add annotation
 let annotation = MKPointAnnotation()
 annotation.coordinate = coordinate
 annotation.title = "Dropped Pin"
 annotation.subtitle = "Custom Location"
 
 mapView.addAnnotation(annotation)
 currentAnnotations.append(annotation)
 
 // Reverse geocode the location
 let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
 CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
 guard let placemark = placemarks?.first else { return }
 
 let address = [
 placemark.thoroughfare,
 placemark.locality,
 placemark.administrativeArea,
 placemark.postalCode,
 placemark.country
 ].compactMap { $0 }.joined(separator: ", ")
 
 annotation.subtitle = address
 }
 }
 
 
 // MARK: - Helper Methods
 private func showLocationServicesAlert() {
 let alert = UIAlertController(
 title: "Location Services Disabled",
 message: "Please enable location services in Settings to use this feature.",
 preferredStyle: .alert
 )
 
 alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
 if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
 UIApplication.shared.open(settingsUrl)
 }
 })
 
 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
 
 present(alert, animated: true)
 }
 
 // Example method to add a route
 func addRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
 let sourcePlacemark = MKPlacemark(coordinate: source)
 let destPlacemark = MKPlacemark(coordinate: destination)
 
 let sourceItem = MKMapItem(placemark: sourcePlacemark)
 let destItem = MKMapItem(placemark: destPlacemark)
 
 let request = MKDirections.Request()
 request.source = sourceItem
 request.destination = destItem
 request.transportType = .automobile
 
 let directions = MKDirections(request: request)
 directions.calculate { [weak self] response, error in
 guard let self = self,
 let response = response else {
 print("Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
 return
 }
 
 let route = response.routes[0]
 self.mapView.addOverlay(route.polyline)
 self.mapView.setVisibleMapRect(
 route.polyline.boundingMapRect,
 edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
 animated: true
 )
 }
 }
 }
 
 // MARK: - MKMapViewDelegate
 extension MapViewController: MKMapViewDelegate {
 func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
 if let polyline = overlay as? MKPolyline {
 let renderer = MKPolylineRenderer(polyline: polyline)
 renderer.strokeColor = .systemBlue
 renderer.lineWidth = 4
 return renderer
 }
 return MKOverlayRenderer(overlay: overlay)
 }
 
 func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
 guard !(annotation is MKUserLocation) else { return nil }
 
 let identifier = "CustomPin"
 
 var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
 
 if annotationView == nil {
 annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
 annotationView?.canShowCallout = true
 
 // Add a button to the callout
 let button = UIButton(type: .detailDisclosure)
 annotationView?.rightCalloutAccessoryView = button
 } else {
 annotationView?.annotation = annotation
 }
 
 return annotationView
 }
 }
 
 // MARK: - CLLocationManagerDelegate
 extension MapViewController: CLLocationManagerDelegate {
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 guard let location = locations.last else { return }
 
 let region = MKCoordinateRegion(
 center: location.coordinate,
 latitudinalMeters: 1000,
 longitudinalMeters: 1000
 )
 mapView.setRegion(region, animated: true)
 
 // Stop updating location if you don't need continuous updates
 // locationManager.stopUpdatingLocation()
 }
 
 func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
 switch manager.authorizationStatus {
 case .authorizedWhenInUse, .authorizedAlways:
 locationManager.startUpdatingLocation()
 case .denied, .restricted:
 showLocationServicesAlert()
 default:
 break
 }
 }
 }
 */
