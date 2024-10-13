//
//  PaymentViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 13/10/24.
//

import UIKit
import Xendit

class PaymentViewController: UIViewController {

    var coordinator: PaymentCoordinator

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let cardNumberTextField = UITextField()
    private let cardExpMonthTextField = UITextField()
    private let cardExpYearTextField = UITextField()
    private let cardCvnTextField = UITextField()
    private let amountTextField = UITextField()
    private let payButton = UIButton(type: .system)

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Initialization

    init(coordinator: PaymentCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up UI elements
        setupUI()

        // Configure Xendit with your publishable key
        Xendit.publishableKey = "" // Replace with your actual publishable key
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        // Add scrollView and contentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Set up constraints for scrollView and contentView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Configure text fields
        [cardNumberTextField, cardExpMonthTextField, cardExpYearTextField, cardCvnTextField, amountTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        cardNumberTextField.placeholder = "Card Number"
        cardNumberTextField.keyboardType = .numberPad

        cardExpMonthTextField.placeholder = "Expiry Month (MM)"
        cardExpMonthTextField.keyboardType = .numberPad

        cardExpYearTextField.placeholder = "Expiry Year (YYYY)"
        cardExpYearTextField.keyboardType = .numberPad

        cardCvnTextField.placeholder = "CVV"
        cardCvnTextField.keyboardType = .numberPad

        amountTextField.placeholder = "Amount"
        amountTextField.keyboardType = .numberPad

        // Configure pay button
        payButton.setTitle("Pay", for: .normal)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        contentView.addSubview(payButton)

        // Configure activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)

        // Layout constraints for UI elements
        NSLayoutConstraint.activate([
            cardNumberTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            cardNumberTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            cardNumberTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: 40),

            cardExpMonthTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: 10),
            cardExpMonthTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            cardExpMonthTextField.widthAnchor.constraint(equalToConstant: 80),
            cardExpMonthTextField.heightAnchor.constraint(equalToConstant: 40),

            cardExpYearTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: 10),
            cardExpYearTextField.leftAnchor.constraint(equalTo: cardExpMonthTextField.rightAnchor, constant: 10),
            cardExpYearTextField.widthAnchor.constraint(equalToConstant: 100),
            cardExpYearTextField.heightAnchor.constraint(equalToConstant: 40),

            cardCvnTextField.topAnchor.constraint(equalTo: cardExpMonthTextField.bottomAnchor, constant: 10),
            cardCvnTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            cardCvnTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            cardCvnTextField.heightAnchor.constraint(equalToConstant: 40),

            amountTextField.topAnchor.constraint(equalTo: cardCvnTextField.bottomAnchor, constant: 10),
            amountTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            amountTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            amountTextField.heightAnchor.constraint(equalToConstant: 40),

            payButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            payButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            payButton.heightAnchor.constraint(equalToConstant: 44),

            activityIndicator.topAnchor.constraint(equalTo: payButton.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions

    @objc private func payButtonTapped() {
        view.endEditing(true)
        createToken()
    }

    // MARK: - Tokenization and Payment

    private func createToken() {
        // Validate inputs
        guard let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty,
              let cardExpMonth = cardExpMonthTextField.text, !cardExpMonth.isEmpty,
              let cardExpYear = cardExpYearTextField.text, !cardExpYear.isEmpty,
              let cardCvn = cardCvnTextField.text, !cardCvn.isEmpty,
              let amountText = amountTextField.text, let amount = Int(amountText) else {
            showAlert(title: "Error", message: "Please fill in all fields correctly.")
            return
        }

        // Validate card data
        guard Xendit.isCardNumberValid(cardNumber: cardNumber) else {
            showAlert(title: "Error", message: "Invalid card number.")
            return
        }

        guard Xendit.isExpiryValid(cardExpirationMonth: cardExpMonth, cardExpirationYear: cardExpYear) else {
            showAlert(title: "Error", message: "Invalid expiry date.")
            return
        }

        guard Xendit.isCvnValid(creditCardCVN: cardCvn) else {
            showAlert(title: "Error", message: "Invalid CVV.")
            return
        }

        // Create CardData object
        let cardData = CardData()
        cardData.cardNumber = cardNumber
        cardData.cardExpMonth = cardExpMonth
        cardData.cardExpYear = cardExpYear
        cardData.cardCvn = cardCvn
        cardData.amount = NSNumber(value: amount)
        cardData.isMultipleUse = false // Set to true if you want a multiple-use token

        // Create tokenization request
        let tokenizationRequest = XenditTokenizationRequest(cardData: cardData, shouldAuthenticate: true)

        // Optionally add billing details and customer information for EMV 3DS
        let billingDetails = XenditBillingDetails()
        billingDetails.givenNames = "Customer First Name" // Replace with actual data
        billingDetails.surname = "Customer Last Name"
        billingDetails.email = "customer@example.com"
        billingDetails.mobileNumber = "+628123456789"

        let address = XenditAddress()
        address.country = "ID"
        address.streetLine1 = "Street Address"
        address.city = "City"
        address.postalCode = "Postal Code"
        billingDetails.address = address

        tokenizationRequest.billingDetails = billingDetails

        let customer = XenditCustomer()
        customer.givenNames = "Customer First Name"
        customer.surname = "Customer Last Name"
        customer.email = "customer@example.com"
        customer.mobileNumber = "+628123456789"
        customer.addresses = [address]

        tokenizationRequest.customer = customer

        // Start activity indicator
        activityIndicator.startAnimating()

        // Create token
        Xendit.createToken(fromViewController: self, tokenizationRequest: tokenizationRequest, onBehalfOf: nil) { [weak self] (token, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }

            if let error = error {
                // Handle error
                self?.showAlert(title: "Error", message: error.message)
                return
            }

            if let token = token {
                // Handle successful tokenization
                self?.handleTokenizationSuccess(token: token)
            }
        }
    }

    private func handleTokenizationSuccess(token: XenditCCToken) {
        // Check the tokenization status
        if token.status == "APPROVED" || token.status == "VERIFIED" {
            // Proceed to charge the token on your backend server
            // Send token.id to your server and perform the charge API call
            // For security reasons, you should not perform the charge from the app

            // Optionally, you can notify the coordinator
            // self.coordinator.didFinishPayment(tokenID: token.id)

            showAlert(title: "Success", message: "Tokenization successful. Token ID: \(token.id)")

            // Example: Navigate to the next screen
            // self.coordinator.showPaymentSuccessScreen()

        } else if token.status == "IN_REVIEW" {
            // Additional authentication is required
            showAlert(title: "Authentication Required", message: "Additional authentication is required.")
        } else {
            // Handle other statuses
            showAlert(title: "Error", message: "Tokenization failed with status: \(token.status)")
        }
    }

    // MARK: - Helper Methods

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
