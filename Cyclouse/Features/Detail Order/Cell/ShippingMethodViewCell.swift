//
//  ShippingMethodViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 22/06/25.
//

import UIKit
import SnapKit

class ShippingMethodViewCell: UITableViewCell {
  
  private let shippingTitleImage: UIImageView = {
    let object = UIImageView(image: .init(systemName: "clock"))
    object.contentMode = .scaleToFill
    object.tintColor = ThemeColor.primary
    return object
  }()
  
  private let shippingTitleLabel: UILabel = {
    LabelFactory.build(text: "Metode Pengiriman", font: ThemeFont.medium(ofSize: 14), textColor: ThemeColor.primary)
  }()
  
  private let titleStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.alignment = .leading
    stack.spacing = 6
    return stack
  }()
  
  private let shippingTypeLabel: UILabel = {
    LabelFactory.build(text: "Jenis", font: ThemeFont.regular(ofSize: 14), textColor: .systemGray)
  }()
  
  private let shippingTypeValue: UILabel = {
    LabelFactory.build(text: "", font: ThemeFont.regular(ofSize: 14), textColor: .white)
  }()
  
  private let estimationLabel: UILabel = {
    LabelFactory.build(text: "Estimasi", font: ThemeFont.regular(ofSize: 14), textColor: .systemGray)
  }()
  
  private let estimationValue: UILabel = {
    LabelFactory.build(text: "", font: ThemeFont.regular(ofSize: 14), textColor: .white)
  }()
  
  private let arrivalLabel: UILabel = {
    LabelFactory.build(text: "Perkiraan Tiba", font: ThemeFont.regular(ofSize: 14), textColor: .systemGray)
  }()
  
  private let arrivalValue: UILabel = {
    LabelFactory.build(text: "", font: ThemeFont.medium(ofSize: 14), textColor: ThemeColor.primary)
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0.15, alpha: 1.0) // Dark gray background
    view.layer.cornerRadius = 16
    return view
  }()
  
  private let contentStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 16
    stack.distribution = .fillEqually
    return stack
  }()
  
  // MARK: - Initialization
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setupViews() {
    backgroundColor = .clear
    selectionStyle = .none
    
    contentView.addSubview(containerView)
    
    // Setup title stack
    titleStackView.addArrangedSubview(shippingTitleImage)
    titleStackView.addArrangedSubview(shippingTitleLabel)
    
    // Create row stacks
    let typeStack = createRowStack(label: shippingTypeLabel, value: shippingTypeValue)
    let estimationStack = createRowStack(label: estimationLabel, value: estimationValue)
    let arrivalStack = createRowStack(label: arrivalLabel, value: arrivalValue)
    
    // Add to content stack
    contentStackView.addArrangedSubview(typeStack)
    contentStackView.addArrangedSubview(estimationStack)
    contentStackView.addArrangedSubview(arrivalStack)
    
    // Add to container
    containerView.addSubview(titleStackView)
    containerView.addSubview(contentStackView)
    
    // Setup constraints with SnapKit
    containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(8)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview().offset(-8)
    }
    
    titleStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.leading.equalToSuperview().offset(8)
      make.trailing.lessThanOrEqualToSuperview().offset(-2)
    }
    
    shippingTitleImage.snp.makeConstraints { make in
      make.width.height.equalTo(20)
    }
    
    contentStackView.snp.makeConstraints { make in
      make.top.equalTo(titleStackView.snp.bottom).offset(16)
      make.leading.equalToSuperview().offset(8)
      make.trailing.equalToSuperview().offset(-8)
      make.bottom.equalToSuperview().offset(-16)
    }
  }
  
  private func createRowStack(label: UILabel, value: UILabel) -> UIStackView {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .equalSpacing
    stack.alignment = .center
    stack.addArrangedSubview(label)
    stack.addArrangedSubview(value)
    return stack
  }
  
  // MARK: - Configuration
  func configure(type: String, estimatedDays: String, estimatedDate: String) {
    shippingTypeValue.text = type
    estimationValue.text = estimatedDays
    arrivalValue.text = estimatedDate
  }
  
  // Alternative configuration method using your order data structure
  func configure(with shipping: Shipping) {
    shippingTypeValue.text = shipping.typeName
    estimationValue.text = shipping.estimatedDays
    arrivalValue.text = shipping.estimatedDeliveryDate
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    shippingTypeValue.text = ""
    estimationValue.text = ""
    arrivalValue.text = ""
  }
}
