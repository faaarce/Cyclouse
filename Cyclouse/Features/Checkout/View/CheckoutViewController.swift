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

enum CheckoutViewSectionType: Int, CaseIterable {
  case address = 0
  case history
  case payment
}

class CheckoutViewController: BaseViewController {

  private var selectedBank: Bank? {
    didSet {
      checkoutButton.isEnabled = selectedBank != nil && selectedAddress != nil
    }
  }
  
  private let checkoutService: CheckoutService
  var coordinator: CheckoutCoordinator
  private let locationManager = CLLocationManager()
  private var selectedAddress: ShippingAddress?
  private let bike: [BikeDatabase]

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
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
    button.isEnabled = false
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
    setupBaseConfiguration()  // Ensure base settings are applied
    setupView()
    layout()
    configureLocationServices()
    totalPrice()
  }

  init(coordinator: CheckoutCoordinator, checkoutService: CheckoutService = CheckoutService(), bike: [BikeDatabase]) {
    self.coordinator = coordinator
    self.checkoutService = checkoutService
    self.bike = bike
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func checkoutButtonTapped() {
    performCheckout()
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

      self.selectedAddress = ShippingAddress(
        street: placemark.thoroughfare ?? "",
        city: placemark.locality ?? "",
        state: placemark.administrativeArea ?? "",
        zipCode: placemark.postalCode ?? "",
        country: placemark.country ?? ""
      )

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
    showAlert(
      title: "Location Services Disabled",
      message: "Please enable location services in Settings to use this feature.",
      primaryAction: UIAlertAction(title: "Settings", style: .default, handler: { _ in
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(settingsUrl)
        }
      }),
      secondaryAction: UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    )
  }

  func setupView() {
    [priceLabel, totalLabel].forEach { totalPriceView.addSubview($0) }
    view.addSubview(checkoutButton)
    view.addSubview(totalPriceView)
    view.addSubview(tableView)
    registerCells()
  }

  func performCheckout() {
    guard let shippingAddress = selectedAddress else {
      handleCheckoutFailure(message: "Please select a delivery address")
      return
    }

    guard let bank = selectedBank else {
      handleCheckoutFailure(message: "Please select a bank for payment")
      return
    }

    let cartItems = bike.map { bike in
      CartItem(productId: bike.productId, quantity: bike.cartQuantity)
    }

    let checkoutCart = CheckoutCart(
      items: cartItems,
      shippingAddress: shippingAddress,
      paymentMethod: PaymentMethod(type: "bankTransfer", bank: bank.name)
    )

    print("Checkout details: \(checkoutCart)")

    isLoading = true  // Indicate loading state

    checkoutService.checkout(checkout: checkoutCart)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard let self = self else { return }
        self.isLoading = false  // Reset loading state
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self.handleNetworkError(error)
        }
      } receiveValue: { [weak self] response in
        print("Checkout successful: \(response)")
        guard let self = self else { return }
        if response.value.success {
          self.handleSuccessfulCheckout(response.value.data)
        } else {
          self.handleCheckoutFailure(message: response.value.message)
        }
      }
      .store(in: &cancellables)
  }

  private func handleNetworkError(_ error: Error) {
    showMessage(
      title: "Error",
      body: "Network error: \(error.localizedDescription)",
      theme: .error
    )
  }

  private func handleCheckoutFailure(message: String) {
    showMessage(
      title: "Checkout Failed",
      body: message,
      theme: .error
    )
  }

  private func handleSuccessfulCheckout(_ checkoutData: CheckoutData) {
    showMessage(
      title: "Checkout Successful",
      body: "Redirecting to payment...",
      theme: .success,
      duration: 1.0
    )

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.coordinator.showPayment(checkoutData)
    }
  }

  private func registerCells() {
    tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "ListProductCell")
    tableView.register(AddressViewCell.self, forCellReuseIdentifier: "AddressCell")
    tableView.register(PaymentViewCell.self, forCellReuseIdentifier: "PaymentCell")
  }

  private func totalPrice() {
    let total = bike.reduce(0.0) { $0 + Double($1.price * $1.cartQuantity) }
    priceLabel.text = total.toRupiah()
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
  }
}

extension CheckoutViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return CheckoutViewSectionType.allCases.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let type = CheckoutViewSectionType(rawValue: section)
    switch type {
    case .address:
      return 1
    case .history:
      return bike.count
    case .payment:
      return 1
    default:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let type = CheckoutViewSectionType(rawValue: indexPath.section)
    switch type {
    case .address:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as? AddressViewCell else {
        return UITableViewCell()
      }

      cell.selectionStyle = .none
      cell.backgroundColor = .clear

      return cell
    case .history:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListProductCell", for: indexPath) as? HistoryTableViewCell else {
        return UITableViewCell()
      }
      cell.selectionStyle = .none
      cell.backgroundColor = .clear
      let item = bike[indexPath.row]
      cell.configure(with: item)

      return cell
    case .payment:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentViewCell else {
        return UITableViewCell()
      }
      cell.selectionStyle = .none
      cell.backgroundColor = .clear
      cell.delegate = self
      return cell
    default:
      return UITableViewCell()
    }
  }
}

extension CheckoutViewController: PaymentViewCellDelegate {
  func didSelectBank(_ bank: Bank) {
    self.selectedBank = bank
    print("Selected bank: \(bank.name)")
    print("Bank Image Name: \(bank.imageName)")
    print("Is Selected: \(bank.isSelected)")

    // Update checkout button state
    checkoutButton.isEnabled = selectedBank != nil && selectedAddress != nil
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
      return UITableView.automaticDimension
    } else if indexPath.section == 1 {
      return 140
    } else {
      return 250
    }
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 100
    } else if indexPath.section == 1 {
      return 140
    } else {
      return 250
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      let mapVC = MapViewController()
      mapVC.modalPresentationStyle = .pageSheet
      mapVC.delegate = self
      if let sheet = mapVC.sheetPresentationController {
        sheet.prefersGrabberVisible = true
        sheet.detents = [.large()]
        present(mapVC, animated: true)
      } else {
        print("Unable to present MapViewController")
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
    
    // Parse the address string and update selectedAddress
    self.selectedAddress = parseAddressString(address)
    
    // Update checkout button state
    checkoutButton.isEnabled = selectedBank != nil && selectedAddress != nil
  }
  
  private func parseAddressString(_ address: String) -> ShippingAddress? {
    // Implement your parsing logic here.
    // This is a simple example that splits the address by commas.
    let components = address.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
    
    guard components.count >= 3 else { return nil }
    
    let street = components[0]
    let city = components[1]
    let country = components.last ?? ""
    
    return ShippingAddress(
      street: street,
      city: city,
      state: "",       // Add state if available
      zipCode: "",     // Add zip code if available
      country: country
    )
  }
}
