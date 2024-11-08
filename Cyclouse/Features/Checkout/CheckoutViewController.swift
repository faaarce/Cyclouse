//
//  CheckoutViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import Combine
import Alamofire
import MapKit
import CoreLocation
import SnapKit

class CheckoutViewController: UIViewController {
  
  private var selectedBank: Bank?
  private let checkoutService: CheckoutService
  var coordinator: CheckoutCoordinator
  private let locationManager = CLLocationManager()
  
  let dummyItems = [
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike")
  ]
  
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    return tableView
  }()
  
  private let totalPriceView: UIView = {
    let object = UIView(frame: .zero)
    object.backgroundColor = ThemeColor.cardFillColor
    return object
  }()
  
  private let checkoutButton: UIButton = {
    let button = UIButton()
    button.setTitle("Checkout", for: .normal)
    button.setTitleColor(ThemeColor.black, for: .normal)
    button.backgroundColor = ThemeColor.primary
    button.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
    return button
  }()
  
  private let priceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.medium(ofSize: 14), textColor: ThemeColor.primary)
  }()
  
  private let totalLabel: UILabel = {
    LabelFactory.build(text: "Total", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = ThemeColor.background
    setupView()
    layout()
    configureLocationServices()
  }
  
  init(coordinator: CheckoutCoordinator, checkoutService: CheckoutService = CheckoutService()) {
    self.coordinator = coordinator
    self.checkoutService = checkoutService
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func checkoutButtonTapped() {
  
  }
  
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
  
 
  private func getUserAddress(from location: CLLocation) {
      let geocoder = CLGeocoder()
      geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
          guard let self = self,
                let placemark = placemarks?.first else {
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
          
          // Update the cell with the new address
          if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddressViewCell {
              DispatchQueue.main.async {
                  cell.updateAddress(addressString)
                  UIView.performWithoutAnimation {
                      self.tableView.beginUpdates()
                      self.tableView.endUpdates()
                  }
              }
          }
      }
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
  
  func setupView() {
    [priceLabel, totalLabel].forEach { totalPriceView.addSubview($0)}
    view.addSubview(checkoutButton)
    view.addSubview(totalPriceView)
    view.addSubview(tableView)
    registerCells()
  }
  
  
  private func registerCells() {
    tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "ListProductCell")
    tableView.register(AddressViewCell.self, forCellReuseIdentifier: "AddressCell")
    tableView.register(PaymentViewCell.self, forCellReuseIdentifier: "PaymentCell")
  }
  
  
  func layout() {
    tableView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.bottom.equalTo(checkoutButton.snp.top)
    }
    
    checkoutButton.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.width.equalTo(113)
      $0.right.equalToSuperview()
      $0.height.equalTo(75)
    }
    
    totalPriceView.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.height.equalTo(75)
      $0.right.equalTo(checkoutButton.snp.left)
    }
    
    totalLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().offset(20)
    }
    
    priceLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalTo(totalLabel.snp.right).offset(5)
    }
    
  }}

extension CheckoutViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return dummyItems.count
    } else {
      return 1
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as? AddressViewCell else { return UITableViewCell() }
      
      cell.selectionStyle = .none
      cell.backgroundColor = .clear
  
      return cell
    } else if indexPath.section == 1 {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListProductCell", for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
      cell.selectionStyle = .none
      cell.backgroundColor = .clear
      let item = dummyItems[indexPath.row]
      cell.configure(with: item)
      
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentViewCell else { return UITableViewCell() }
      cell.selectionStyle = .none
      cell.backgroundColor = .clear
      cell.delegate = self
      return cell
    }
    return UITableViewCell()
  }
}

extension CheckoutViewController: PaymentViewCellDelegate {
    func didSelectBank(_ bank: Bank) {
        self.selectedBank = bank
        print("Selected bank: \(bank.name)")
        print("Bank Image Name: \(bank.imageName)")
        print("Is Selected: \(bank.isSelected)")
        
        // You can also use this selection for your checkout process
        if let selectedBank = selectedBank {
            // Enable checkout button if needed
            checkoutButton.isEnabled = true
            // You might want to store this for the checkout process
            print("Ready to checkout with bank: \(selectedBank.name)")
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CheckoutViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        getUserAddress(from: location)
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
}

extension CheckoutViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       if indexPath.section == 0 {
           return UITableView.automaticDimension  // Change to automatic dimension
       } else if indexPath.section == 1 {
         return 140
     } else {
       return 20
     }
   }
   
   func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
       if indexPath.section == 0 {
           return 100  // Provide an estimated height
       } else if indexPath.section == 1{
           return 140
       } else {
         return 20
       }
   }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      let placesTVC = MapViewController()
      placesTVC.modalPresentationStyle = .pageSheet
      placesTVC.delegate = self
      if let sheet = placesTVC.sheetPresentationController {
        sheet.prefersGrabberVisible = true
        sheet.detents = [.large()]
        present(placesTVC, animated: true)
      }
      else {
        print("test")
      }
      
    }
  }
}

extension CheckoutViewController: AddressUpdateDelegate {
  func didUpdateAddress(_ address: String) {
    if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddressViewCell {
                cell.updateAddress(address)
            }
    UIView.performWithoutAnimation {
                   tableView.beginUpdates()
                   tableView.endUpdates()
               }
    tableView.reloadData()
  }
}
/*
 class CheckoutViewController: UIViewController {
 
 // MARK: - Properties
 var coordinator: CheckoutCoordinator
 private var cancellables = Set<AnyCancellable>()
 private let checkoutService: CheckoutService
 private let locationManager = CLLocationManager()
 private var selectedAddress: ShippingAddress?
 
 // MARK: - UI Components
 private let mapView: MKMapView = {
 let map = MKMapView()
 map.translatesAutoresizingMaskIntoConstraints = false
 map.layer.cornerRadius = 12
 map.clipsToBounds = true
 return map
 }()
 
 private let instructionLabel: UILabel = {
 let label = UILabel()
 label.translatesAutoresizingMaskIntoConstraints = false
 label.text = "Tap on the map to select delivery location"
 label.textAlignment = .center
 label.font = .systemFont(ofSize: 14)
 label.textColor = .gray
 return label
 }()
 
 private let addressLabel: UILabel = {
 let label = UILabel()
 label.translatesAutoresizingMaskIntoConstraints = false
 label.numberOfLines = 0
 label.font = .systemFont(ofSize: 16, weight: .medium)
 return label
 }()
 
 private let confirmLocationButton: UIButton = {
 let button = UIButton(type: .system)
 button.translatesAutoresizingMaskIntoConstraints = false
 button.setTitle("Use This Location", for: .normal)
 button.backgroundColor = .systemGreen
 button.setTitleColor(.white, for: .normal)
 button.layer.cornerRadius = 8
 button.isHidden = true // Initially hidden until location is selected
 return button
 }()
 
 private let checkoutButton: UIButton = {
 let button = UIButton(type: .system)
 button.translatesAutoresizingMaskIntoConstraints = false
 button.setTitle("Confirm Checkout", for: .normal)
 button.backgroundColor = .systemBlue
 button.setTitleColor(.white, for: .normal)
 button.layer.cornerRadius = 8
 button.isEnabled = false
 button.alpha = 0.5
 return button
 }()
 
 // MARK: - Lifecycle
 override func viewDidLoad() {
 super.viewDidLoad()
 view.backgroundColor = ThemeColor.background
 setupUI()
 configureLocationServices()
 setupMapView()
 }
 
 init(coordinator: CheckoutCoordinator, checkoutService: CheckoutService = CheckoutService()) {
 self.coordinator = coordinator
 self.checkoutService = checkoutService
 super.init(nibName: nil, bundle: nil)
 }
 
 required init?(coder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 // MARK: - UI Setup
 private func setupUI() {
 view.addSubview(mapView)
 view.addSubview(instructionLabel)
 view.addSubview(addressLabel)
 view.addSubview(confirmLocationButton)
 view.addSubview(checkoutButton)
 
 NSLayoutConstraint.activate([
 // Map View Constraints
 mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
 mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
 mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
 mapView.heightAnchor.constraint(equalToConstant: 200),
 
 // Instruction Label Constraints
 instructionLabel.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8),
 instructionLabel.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 8),
 instructionLabel.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -8),
 
 // Address Label Constraints
 addressLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
 addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
 addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
 
 // Confirm Location Button Constraints
 confirmLocationButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 16),
 confirmLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
 confirmLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
 confirmLocationButton.heightAnchor.constraint(equalToConstant: 44),
 
 // Checkout Button Constraints
 checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
 checkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
 checkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
 checkoutButton.heightAnchor.constraint(equalToConstant: 50)
 ])
 
 checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
 confirmLocationButton.addTarget(self, action: #selector(confirmLocationTapped), for: .touchUpInside)
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
 annotation.title = "Delivery Location"
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
 self?.addressLabel.text = "Unable to find address"
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
 
 // Update UI
 self.addressLabel.text = "Selected Address:\n\(addressString)"
 self.confirmLocationButton.isHidden = false
 }
 }
 
 @objc private func confirmLocationTapped() {
 guard selectedAddress != nil else { return }
 
 // Enable checkout button
 checkoutButton.isEnabled = true
 checkoutButton.alpha = 1.0
 
 // Hide confirm button and show success message
 confirmLocationButton.isHidden = true
 instructionLabel.text = "✓ Delivery location confirmed"
 instructionLabel.textColor = .systemGreen
 }
 
 @objc private func checkoutButtonTapped() {
 performCheckout()
 }
 
 // MARK: - Checkout Logic
 func performCheckout() {
 guard let shippingAddress = selectedAddress else {
 handleCheckoutFailure(message: "Please select a delivery address")
 return
 }
 
 let cartItems = [
 CartItem(productId: "FB001", quantity: 1),
 CartItem(productId: "HB001", quantity: 2)
 ]
 
 let checkoutCart = CheckoutCart(
 items: cartItems,
 shippingAddress: shippingAddress
 )
 
 checkoutService.checkout(checkout: checkoutCart)
 .receive(on: DispatchQueue.main)
 .sink { [weak self] completion in
 switch completion {
 case .finished:
 break
 case .failure(let error):
 self?.handleNetworkError(error)
 }
 } receiveValue: { [weak self] response in
 if response.value.success {
 self?.handleSuccessfulCheckout(response.value.data)
 } else {
 self?.handleCheckoutFailure(message: response.value.message)
 }
 }
 .store(in: &cancellables)
 }
 
 // MARK: - Alert Handlers
 private func handleSuccessfulCheckout(_ checkoutData: CheckoutData) {
 let alert = UIAlertController(
 title: "Checkout Successful",
 message: "Your order ID is: \(checkoutData.id)",
 preferredStyle: .alert
 )
 alert.addAction(UIAlertAction(title: "OK", style: .default))
 present(alert, animated: true)
 }
 
 private func handleCheckoutFailure(message: String) {
 let alert = UIAlertController(
 title: "Checkout Failed",
 message: message,
 preferredStyle: .alert
 )
 alert.addAction(UIAlertAction(title: "OK", style: .default))
 present(alert, animated: true)
 }
 
 private func handleNetworkError(_ error: Error) {
 let alert = UIAlertController(
 title: "Error",
 message: "Network error: \(error.localizedDescription)",
 preferredStyle: .alert
 )
 alert.addAction(UIAlertAction(title: "OK", style: .default))
 present(alert, animated: true)
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
 
 // MARK: - MKMapViewDelegate
 extension CheckoutViewController: MKMapViewDelegate {
 func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
 guard !(annotation is MKUserLocation) else { return nil }
 
 let identifier = "DeliveryPin"
 
 var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
 
 if annotationView == nil {
 annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
 annotationView?.canShowCallout = true
 } else {
 annotationView?.annotation = annotation
 }
 
 return annotationView
 }
 }
 
 // MARK: - CLLocationManagerDelegate
 extension CheckoutViewController: CLLocationManagerDelegate {
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
 }
 */
