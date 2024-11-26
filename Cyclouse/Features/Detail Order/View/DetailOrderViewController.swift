//
//  DetailOrderViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 26/11/24.
//
import JDStatusBarNotification
import UIKit

class DetailOrderViewController: BaseViewController {
    
  
    // MARK: - Properties
  private var coordinator: DetailOrderCoordinator
  private var orderData: OrderHistory
  
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
    
    private let priceLabel: UILabel = {
        LabelFactory.build(
            text: "Rp 5,000,000",
            font: ThemeFont.medium(ofSize: 14),
            textColor: ThemeColor.primary
        )
    }()
    
    private let totalLabel: UILabel = {
        LabelFactory.build(
            text: "Total",
            font: ThemeFont.medium(ofSize: 12),
            textColor: ThemeColor.labelColorSecondary
        )
    }()
  
  init(coordinator: DetailOrderCoordinator, orderData: OrderHistory) {
      self.coordinator = coordinator
    self.orderData = orderData
      super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        registerCells()
      configureWithOrderData()
    }
    
    // MARK: - Setup Methods
    override func setupViews() {
        title = "Order Detail"
        view.backgroundColor = ThemeColor.background
        
        [priceLabel, totalLabel].forEach { totalPriceView.addSubview($0) }
        [tableView, totalPriceView].forEach { view.addSubview($0) }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(totalPriceView.snp.top)
        }
        
        totalPriceView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(75)
        }
        
        totalLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(totalLabel.snp.right).offset(5)
        }
    }
  
  private func configureWithOrderData() {
         // Update header
         if let headerView = tableView.headerView(forSection: 1) as? OrderSectionHeaderView {
             headerView.configure(
                 with: "Order Items",
                 orderNumber: orderData.orderId,
                 paymentMethod: orderData.paymentMethod.bank
             )
         }
         
         // Update total price
         priceLabel.text = orderData.total.toRupiah()
         
         // Reload table to update cells
         tableView.reloadData()
     }
    
    private func registerCells() {
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "ListProductCell")
        tableView.register(AddressViewCell.self, forCellReuseIdentifier: "AddressCell")
        tableView.register(OrderPriceDetailCell.self, forCellReuseIdentifier: OrderPriceDetailCell.identifier)
      tableView.register(OrderSectionHeaderView.self,
                             forHeaderFooterViewReuseIdentifier: OrderSectionHeaderView.identifier)
    }
}

// MARK: - UITableViewDataSource
extension DetailOrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3  // Address and Order Items sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:  // Address section
            return 1
        case 1:  // Order items section
          return orderData.items.count
        case 2:  // Price details section
              return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "AddressCell",
                for: indexPath
            ) as? AddressViewCell else {
                return UITableViewCell()
            }
          cell.updateAddress(orderData.shippingAddress)
            // Configure address cell
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ListProductCell",
                for: indexPath
            ) as? HistoryTableViewCell else {
                return UITableViewCell()
            }
          let item = orderData.items[indexPath.row]
          cell.configureDetail(order: item)
          cell.backgroundColor = .clear
          cell.contentView.backgroundColor = .clear
          cell.backgroundView = nil
          cell.backgroundConfiguration = .clear()
          
            return cell
          
        case 2:
              guard let cell = tableView.dequeueReusableCell(
                  withIdentifier: OrderPriceDetailCell.identifier,
                  for: indexPath
              ) as? OrderPriceDetailCell else {
                  return UITableViewCell()
              }
              // Configure price detail cell
          cell.configure(subtotal: Double(orderData.paymentDetails.amount), shippingCost: 0)
              return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension DetailOrderViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case 0:  // Address section
      return UITableView.automaticDimension
    case 1:  // Order items section
      return 140
    case 2:  // Price details section
      return UITableView.automaticDimension
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case 0:
      return 100
    case 1:
      return 140
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == 1 else { return nil }  // Only show header for Order Items section
    
    let headerView = tableView.dequeueReusableHeaderFooterView(
      withIdentifier: OrderSectionHeaderView.identifier
    ) as? OrderSectionHeaderView
    
    headerView?.configure(with: "Order Items", orderNumber: String(orderData.orderId.suffix(12)), paymentMethod: "\(orderData.paymentMethod.bank) Virtual Account")
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 1:  // Order Items section
      return 60
    default:
      return 0
    }
    
    
  }
}


class OrderSectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "OrderSectionHeaderView"
    
    // MARK: - UI Components
  private let sectionTitleLabel: UILabel = {
        LabelFactory.build(
             text: "",
             font: ThemeFont.medium(ofSize: 14),
             textColor: .white)
     }()
  
  private let paymentMethodTitleLabel: UILabel = {
    LabelFactory.build(text: "", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let paymentMethodLabel: UILabel = {
    LabelFactory.build(text: "", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  
  
  private let orderNumberLabel: UILabel = {
     LabelFactory.build(
             text: "",
             font: ThemeFont.medium(ofSize: 14),
             textColor: .white
         )
     }()
     
     private let copyButton: UIButton = {
         let button = UIButton()
         button.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
         button.tintColor = ThemeColor.primary
         button.addTarget(self, action: #selector(copyOrderNumberTapped), for: .touchUpInside)
         return button
     }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
  
  // MARK: - Properties
      private var orderNumber: String = ""
    
    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
  private func setupViews() {
         contentView.backgroundColor = .clear
         contentView.addSubview(containerView)
         containerView.addSubview(sectionTitleLabel)
         containerView.addSubview(orderNumberLabel)
    containerView.addSubview(paymentMethodTitleLabel)
    containerView.addSubview(paymentMethodLabel)
         containerView.addSubview(copyButton)
     }
     
  private func setupConstraints() {
          containerView.snp.makeConstraints { make in
              make.left.right.equalToSuperview()
              make.top.bottom.equalToSuperview()
          }
          
          // Section Title Label at the top-left
          sectionTitleLabel.snp.makeConstraints { make in
              make.left.equalToSuperview()
              make.top.equalToSuperview().offset(8)
          }
          
          // Copy Button at the top-right
          copyButton.snp.makeConstraints { make in
              make.right.equalToSuperview()
              make.centerY.equalTo(sectionTitleLabel.snp.centerY)
              make.width.height.equalTo(24)
          }
          
          // Order Number Label to the left of the Copy Button
          orderNumberLabel.snp.makeConstraints { make in
              make.right.equalTo(copyButton.snp.left).offset(-8)
              make.centerY.equalTo(sectionTitleLabel.snp.centerY)
          }
          
          // Payment Method Title Label below the Section Title Label
          paymentMethodTitleLabel.snp.makeConstraints { make in
              make.left.equalTo(sectionTitleLabel)
              make.top.equalTo(sectionTitleLabel.snp.bottom).offset(8)
              make.bottom.equalToSuperview().offset(-8)
          }
          
          // Payment Method Label aligned with Payment Method Title Label, but on the trailing side
          paymentMethodLabel.snp.makeConstraints { make in
              make.right.equalToSuperview()
              make.centerY.equalTo(paymentMethodTitleLabel.snp.centerY)
          }
      }


  // MARK: - Configuration
  func configure(with title: String, orderNumber: String, paymentMethod: String) {
         sectionTitleLabel.text = title
         orderNumberLabel.text = orderNumber
         paymentMethodTitleLabel.text = "Payment Method"
         paymentMethodLabel.text = paymentMethod
         self.orderNumber = orderNumber
     }

  // MARK: - Copy Button Action
  @objc private func copyOrderNumberTapped() {
      // Copy order number to clipboard
      UIPasteboard.general.string = orderNumber
      
      // Animate button
      animateCopyButton()
      
      // Show notification
      showCopyNotification()
  }
  
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
          "Order number copied!",
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
}
