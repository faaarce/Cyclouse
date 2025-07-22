//
//  PaymentViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 08/11/24.
//

import UIKit
import SnapKit

protocol PaymentViewCellDelegate: AnyObject {
  func didSelectBank(_ bank: Bank)
}

extension UIView {
  func add(_ views: [UIView]) {
    views.forEach {
      self.addSubview($0)
    }
  }
}


class PaymentViewCell: UITableViewCell {
  
  weak var delegate: PaymentViewCellDelegate?
  
  private let containerView: UIView = {
    let object = UIView(frame: .zero)
    object.backgroundColor = ThemeColor.cardFillColor
    object.layer.cornerRadius = 12
    object.layer.borderWidth = 1
    object.layer.borderColor = UIColor.gray.cgColor
    return object
  }()
  
  private let iconBankImage: UIImageView = {
    let object = UIImageView(image: .init(systemName: "creditcard.fill"))
    object.contentMode = .scaleAspectFit
    object.tintColor = ThemeColor.primary
    return object
  }()
  
  private let transferBankHeaderTitle: UILabel = {
    LabelFactory.build(text: "Transfer Bank", font: ThemeFont.semibold(ofSize: 12))
  }()
  
  
  
  private let paymentMethodTitle: UILabel = {
    LabelFactory.build(text: "Payment Method", font: ThemeFont.medium(ofSize: 12))
  }()
  
  
  // Vertical stack view to contain all bank stacks
  private lazy var banksVerticalStackView: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.spacing = 12
    view.distribution = .fillEqually
    view.alignment = .fill
    return view
  }()
  
  private var banks: [Bank] = [
    Bank(name: "Bank BCA", imageName: "bank bca", isSelected: false),
    Bank(name: "Bank BNI", imageName: "bank bni", isSelected: false),
    Bank(name: "Bank Mandiri", imageName: "bank mandiri", isSelected: false),
    Bank(name: "Bank BRI", imageName: "bank bri", isSelected: false)
  ]
  
  private var bankStackViews: [UIStackView] = []
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
    layout()
    createBankStackViews()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    setupView()
    layout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
}

extension PaymentViewCell {
  private func createBankStackViews() {
    banks.forEach { bank in
      let stackView = createBankStackView(for: bank)
      bankStackViews.append(stackView)
      banksVerticalStackView.addArrangedSubview(stackView)
    }
  }
  
  // MARK: - Selection Handling
  @objc private func bankSelected(_ sender: UIButton) {
    let selectedIndex = sender.tag
    print("Bank button tapped with tag: \(sender.tag)")
    
    
    // Update model
    banks = banks.enumerated().map { index, bank in
      var updatedBank = bank
      updatedBank.isSelected = index == selectedIndex
      return updatedBank
    }
    
    // Call delegate with selected bank
    if banks.indices.contains(selectedIndex) {
      let selectedBank = banks[selectedIndex]
      print("Bank selected in cell: \(selectedBank.name)") // Debug print
      delegate?.didSelectBank(selectedBank)
    }
    
    // Update UI
    updateRadioButtons()
  }
  
  private func updateRadioButtons() {
    bankStackViews.enumerated().forEach { index, stackView in
      if let checkButton = stackView.arrangedSubviews.last as? UIButton {
        let image = banks[index].isSelected ?
        UIImage(systemName: "circle.circle.fill") :
        UIImage(systemName: "circle.circle")
        checkButton.tintColor = banks[index].isSelected ? ThemeColor.primary : ThemeColor.labelColorSecondary
        checkButton.setImage(image, for: .normal)
      }
    }
  }
  
  private func createBankStackView(for bank: Bank) -> UIStackView {
    let bankImage = UIImageView(image: .init(named: bank.imageName))
    bankImage.contentMode = .scaleAspectFit
    bankImage.layer.masksToBounds = true
    bankImage.layer.cornerRadius = 8
    
    let bankTitle = LabelFactory.build(text: bank.name, font: ThemeFont.medium(ofSize: 12))
    
    let checkButton = UIButton(type: .system)
    checkButton.setImage(UIImage(systemName: "circle.circle"), for: .normal)
    checkButton.tintColor = ThemeColor.labelColorSecondary
    checkButton.contentMode = .scaleAspectFit
    checkButton.tag = bankStackViews.count // Use count as tag for identification
    checkButton.addTarget(self, action: #selector(bankSelected(_:)), for: .touchUpInside)
    
    let spacerView = UIView()
    spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    let stackView = UIStackView(arrangedSubviews: [bankImage, bankTitle, spacerView, checkButton])
    stackView.axis = .horizontal
    stackView.spacing = 6
    stackView.distribution = .fill
    stackView.alignment = .center
    
    // Set constraints for bankImage and checkButton
    bankImage.snp.makeConstraints {
      $0.width.height.equalTo(24)
    }
    
    checkButton.snp.makeConstraints {
      $0.width.height.equalTo(16)
    }
    
    return stackView
  }
  
  func setupView() {
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    contentView.add([paymentMethodTitle, containerView])
    containerView.add([iconBankImage, transferBankHeaderTitle, banksVerticalStackView])
  }
  
  func layout() {
    
    iconBankImage.snp.makeConstraints {
      $0.width.equalTo(16)
      $0.height.equalTo(16)
    }
    
    paymentMethodTitle.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.top.equalToSuperview().offset(8)
    }
    
    iconBankImage.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.left.equalToSuperview().offset(8)
    }
    
    transferBankHeaderTitle.snp.makeConstraints {
      $0.top.equalTo(iconBankImage.snp.top)
      $0.left.equalTo(iconBankImage.snp.right).offset(4)
    }
    
    containerView.snp.makeConstraints {
      $0.left.right.equalToSuperview()
      $0.top.equalTo(paymentMethodTitle.snp.bottom).offset(20)
      $0.bottom.equalTo(banksVerticalStackView.snp.bottom).offset(8)
    }
    
    banksVerticalStackView.snp.makeConstraints {
      $0.left.equalToSuperview().offset(8)
      $0.top.equalTo(iconBankImage.snp.bottom).offset(12)
      $0.right.equalToSuperview().offset(-8)
    }
    
  }
}
