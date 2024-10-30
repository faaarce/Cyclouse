//
//  CheckoutViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 29/10/24.
//

import UIKit
import Combine
import Alamofire

class CheckoutViewController: UIViewController {
  
  var coordinator: CheckoutCoordinator
  
  private var cancellables = Set<AnyCancellable>()
  private let checkoutService: CheckoutService
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = ThemeColor.background
    performCheckout()
  }
  
  init(coordinator: CheckoutCoordinator, checkoutService: CheckoutService = CheckoutService()) {
    self.coordinator = coordinator
    self.checkoutService = checkoutService
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func performCheckout() {
    // Create the request body
    let cartItems = [
      CartItem(productId: "FB001", quantity: 1),
      CartItem(productId: "HB001", quantity: 2)
    ]
    
    let shippingAddress = ShippingAddress(
      street: "123 Main St",
      city: "Anytown",
      state: "CA",
      zipCode: "12345",
      country: "USA"
    )
    
    let checkoutCart = CheckoutCart(
      items: cartItems,
      shippingAddress: shippingAddress
    )
    
    // Make the API call using your service
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
  
  private func handleSuccessfulCheckout(_ checkoutData: CheckoutData) {
    // Show success alert
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
}

  // MARK: - Debug Print Extensions
  extension CheckoutViewController {
      private func debugPrintRequest(_ checkoutCart: CheckoutCart) {
          print("""
          🛒 Checkout Request:
          Items:
          \(checkoutCart.items.map { "- ProductID: \($0.productId), Quantity: \($0.quantity)" }.joined(separator: "\n"))
          
          📍 Shipping Address:
          - Street: \(checkoutCart.shippingAddress.street)
          - City: \(checkoutCart.shippingAddress.city)
          - State: \(checkoutCart.shippingAddress.state)
          - ZIP: \(checkoutCart.shippingAddress.zipCode)
          - Country: \(checkoutCart.shippingAddress.country)
          """)
          
          if let token = TokenManager.shared.getToken() {
              print("🔑 Authorization Token: \(String(token.prefix(20)))...")
          } else {
              print("⚠️ No Authorization Token Found!")
          }
      }
  }
