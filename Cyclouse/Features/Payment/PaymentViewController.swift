//
//  PaymentViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 13/10/24.
//

import UIKit
import SnapKit
import JDStatusBarNotification

class PaymentViewController: UIViewController {
  
  var coordinator: PaymentCoordinator
  var paymentDetail: CheckoutData
  
  private let paymentHeaderLabel: UILabel = {
    LabelFactory.build(text: "Make payment immediately", font: ThemeFont.medium(ofSize: 14))
  }()
  
  private let paymentInstructionLabel: UILabel = {
    LabelFactory.build(text: "Please make payment via the following account number", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let vaCardView: UIView = {
    let view = UIView()
    view.backgroundColor = ThemeColor.cardFillColor
    view.layer.cornerRadius = 10
    return view
  }()
  
  private let bankLogoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "bca")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let copyButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "document.on.document.fill"), for: .normal)
    button.tintColor = ThemeColor.primary
    button.addTarget(self, action: #selector(copyVANumberTapped), for: .touchUpInside)
    return button
  }()
  
  private let vaNumberTitleLabel: UILabel = {
    LabelFactory.build(text: "No. Virtual Account BCA:", font: ThemeFont.semibold(ofSize: 10), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let vaNumberLabel: UILabel = {
    LabelFactory.build(text: "883360812438840", font: ThemeFont.medium(ofSize: 12))
  }()
  
  private let accountNameLabel: UILabel = {
    LabelFactory.build(text: "a.n Cyclouse", font: ThemeFont.semibold(ofSize: 10))
  }()
  
  private let paymentDeadlineLabel: UILabel = {
    LabelFactory.build(text: "Transfer Before 18.51 WIB, Tuesday, August 22, 2024", font: ThemeFont.semibold(ofSize: 10), textColor: UIColor(hex: "FFC200"))
  }()
  
  private let orderDetail: UILabel = {
    LabelFactory.build(text: "Order Detail", font: ThemeFont.medium(ofSize: 14), textAlignment: .left)
  }()
  
  private let normalPriceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let normalPriceTitleLabel: UILabel = {
    LabelFactory.build(text: "Sub Total" , font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private lazy var priceHStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [normalPriceTitleLabel, normalPriceLabel])
    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.alignment = .fill
    stackView.distribution = .equalCentering
    return stackView
  }()
  
  private lazy var vaStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [vaNumberTitleLabel, vaNumberLabel])
    stackView.axis = .vertical
    stackView.spacing = 2
    stackView.alignment = .leading
    return stackView
  }()
  
  private lazy var shippingTitleLabel: UILabel = {
    LabelFactory.build(text: "Shipping Cost" , font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let shippingPriceLabel: UILabel = {
    LabelFactory.build(text: "Rp 20,000", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private lazy var detalPriceVStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [priceHStackView, shippingPriceHStackView, dividerView, totalHStackview])
    stackView.axis = .vertical
    stackView.spacing = 12
    stackView.alignment = .fill
    stackView.distribution = .fill
    return stackView
  }()
  
  private lazy var shippingPriceHStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [shippingTitleLabel, shippingPriceLabel])
    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.alignment = .fill
    stackView.distribution = .equalCentering
    return stackView
  }()
  
  private let totalLabel: UILabel = {
    LabelFactory.build(text: "Total", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let totalPriceLabel: UILabel = {
    LabelFactory.build(text: "Rp 50,000", font: ThemeFont.medium(ofSize: 16), textColor: ThemeColor.primary)
  }()
  
  private lazy var totalHStackview: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [totalLabel, totalPriceLabel])
    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.alignment = .fill
    stackView.distribution = .equalCentering
    return stackView
  }()
  
  private let dividerView : UIView = {
    let view = UIView()
    view.backgroundColor = ThemeColor.cardFillColor
    view.snp.makeConstraints { make in
      make.height.equalTo(1)
    }
    return view
  }()
  
  
  init(coordinator: PaymentCoordinator, paymentDetail: CheckoutData) {
    self.coordinator = coordinator
    self.paymentDetail = paymentDetail
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    setupViews()
    layout()
    configureWithPaymentDetails()
  }
  
  private func configureWithPaymentDetails() {
    
    vaNumberTitleLabel.text = "No. Virtual Account \(paymentDetail.paymentDetails.bank):"
    vaNumberLabel.text = paymentDetail.paymentDetails.virtualAccountNumber
    let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
           if let date = dateFormatter.date(from: paymentDetail.paymentDetails.expiryDate) {
               dateFormatter.dateFormat = "HH.mm 'WIB', EEEE, MMMM dd, yyyy"
               dateFormatter.locale = Locale(identifier: "en_US")
               let formattedDate = dateFormatter.string(from: date)
               paymentDeadlineLabel.text = "Transfer Before \(formattedDate)"
           }
           
           // Configure prices
           let totalAmount = Double(paymentDetail.total)
           
           // Calculate subtotal (total of items)
           let subtotal = paymentDetail.items.reduce(0.0) { result, item in
               result + (Double(item.price) * Double(item.quantity))
           }
           
           // Calculate shipping (difference between total and subtotal)
           let shipping = totalAmount - subtotal
           
           // Update price labels
           normalPriceLabel.text = subtotal.toRupiah()
           shippingPriceLabel.text = shipping.toRupiah()
           totalPriceLabel.text = totalAmount.toRupiah()
           
           // Configure payment method
           let bankName = paymentDetail.paymentMethod.bank
           let bankImageName = bankName.lowercased()
           bankLogoImageView.image = UIImage(named: bankImageName)
  }
  
  private func setupNotificationStyle() {
          let styleName = "CopyStyle"
          NotificationPresenter.shared.addStyle(named: styleName) { style in
              style.backgroundStyle.backgroundColor = ThemeColor.primary
              style.textStyle.textColor = ThemeColor.cardFillColor
              style.textStyle.font = ThemeFont.bold(ofSize: 14)
              style.subtitleStyle.textColor = ThemeColor.cardFillColor
              style.subtitleStyle.font = ThemeFont.medium(ofSize: 12)
              style.progressBarStyle.barColor = ThemeColor.cardFillColor
              style.progressBarStyle.barHeight = 0.1
              return style
          }
      }
  
  @objc private func copyVANumberTapped() {
         // Copy VA number to clipboard
         UIPasteboard.general.string = vaNumberLabel.text
         
         // Animate button
         animateCopyButton()
         
         // Show notification
         showCopyNotification()
     }
     
     // MARK: - Helper Methods
     private func animateCopyButton() {
         UIView.animate(withDuration: 0.1, animations: {
             self.copyButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
         }) { _ in
             UIView.animate(withDuration: 0.1) {
                 self.copyButton.transform = .identity
             }
         }
     }
     
     private func showCopyNotification() {
         // Create the left view (copy icon)
         let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
         let image = UIImage(systemName: "doc.on.doc.fill", withConfiguration: imageConfig)
         let imageView = UIImageView(image: image)
         imageView.tintColor = ThemeColor.cardFillColor
         
         // Present the notification
         NotificationPresenter.shared.present(
             "Virtual Account number copied!",
             subtitle: "You can paste it now",
             styleName: "CopyStyle"
         ) { presenter in
             presenter.displayLeftView(imageView)
             
             // Add progress bar animation
             presenter.animateProgressBar(to: 1.0, duration: 1.5) { presenter in
                 presenter.dismiss()
             }
         }
     }
  
  // MARK: - UI Setup
  
  private func setupViews() {
    view.addSubview(detalPriceVStackView)
    view.addSubview(paymentHeaderLabel)
    view.addSubview(paymentInstructionLabel)
    [bankLogoImageView, vaStackView, accountNameLabel, paymentDeadlineLabel, copyButton].forEach(vaCardView.addSubview(_:))
    view.addSubview(orderDetail)
    view.addSubview(vaCardView)
    view.backgroundColor = ThemeColor.background
  }
  
  private func layout() {
    paymentHeaderLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(4)
    }
    
    detalPriceVStackView.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.top.equalTo(orderDetail.snp.bottom).offset(12)
    }
    
    orderDetail.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.top.equalTo(vaCardView.snp.bottom).offset(12)
    }
    
    paymentInstructionLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(paymentHeaderLabel.snp.bottom).offset(12)
    }
    
    vaCardView.snp.makeConstraints {
      $0.top.equalTo(paymentInstructionLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().offset(-16)
    }
    
    copyButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-16)
      $0.top.equalTo(vaStackView.snp.top)
    }
    
    bankLogoImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.top.equalToSuperview().offset(4)
      $0.width.height.equalTo(50)
    }
    
    vaStackView.snp.makeConstraints {
      $0.leading.equalTo(bankLogoImageView.snp.trailing).offset(8)
      $0.centerY.equalTo(bankLogoImageView)
    }
    
    accountNameLabel.snp.makeConstraints {
      $0.top.equalTo(vaNumberLabel.snp.bottom).offset(12)
      $0.centerX.equalToSuperview()
    }
   
    
    paymentDeadlineLabel.snp.makeConstraints {
      $0.top.equalTo(accountNameLabel.snp.bottom).offset(8)
      $0.bottom.equalTo(vaCardView.snp.bottom).offset(-8)
      $0.centerX.equalToSuperview()
    }
  }
}
