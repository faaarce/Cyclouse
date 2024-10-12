//
//  CartViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//

import UIKit

protocol CartCellDelegate: AnyObject {
  func minusButton(_ cell: CartViewCell)
  func plusButton(_ cell: CartViewCell)
  func deleteButton(_ cell: CartViewCell, indexPath: IndexPath)
}

class CartViewCell: UITableViewCell {
  
  weak var delegate: CartCellDelegate?
  var bike: BikeV2?
  var indexPath: IndexPath?
  
  var quantity: Int = 1
  
  private let checkButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
    object.tintColor = ThemeColor.primary
    object.contentMode = .scaleAspectFit
    return object
  }()
  
  private let cartImage: UIImageView = {
    let view = UIImageView(image: .init(named: "onthel"))
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  let bikeNameLabel: UILabel = {
    LabelFactory.build(text: "TDR 3.000 - Mountain Bike", font: ThemeFont.semibold(ofSize: 14), textColor: .white)
  }()
  
  let bikePriceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.bold(ofSize: 14), textColor: ThemeColor.primary)
  }()
  
  private let plusButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "plus.app"), for: .normal)
    object.tintColor = ThemeColor.primary
    object.contentMode = .scaleAspectFit
    object.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    return object
  }()
  
  private let minusButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "minus.square"), for: .normal)
    object.tintColor = ThemeColor.primary
    object.contentMode = .scaleAspectFit
    object.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
    return object
  }()
  
  private let deleteProductButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "trash.fill"), for: .normal)
    object.tintColor = .red
    object.contentMode = .scaleAspectFit
    object.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    return object
  }()
  
  private let quantityLabel: UILabel = {
    LabelFactory.build(text: "1", font: ThemeFont.semibold(ofSize: 14), textColor: .white)
  }()
  
  
  
  private let hStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 10
    stack.alignment = .fill
    stack.distribution = .fillEqually
    return stack
  }()
  
  private let vStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 8
    stack.alignment = .leading
    stack.distribution = .fill
    return stack
  }()
  
  private let productCardView: UIView = {
    let object = UIView(frame: .zero)
    object.backgroundColor = .clear
    object.layer.borderWidth = 2
    object.layer.borderColor = ThemeColor.cardFillColor.cgColor
    object.layer.cornerRadius = 10
    object.layer.masksToBounds = true
    return object
  }()
  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
    layout()
  }
  
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
    layout()
  }
  
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupViews()
    layout()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    setupViews()
    layout()
  }
  
  func configure(with bike: BikeV2) {
    self.bike = bike
    bikeNameLabel.text = bike.name
    bikePriceLabel.text = bike.price.toRupiah()
    quantityLabel.text = "\(bike.cartQuantity)"
    updateButtonState(stockQuantity: bike.stockQuantity, cartQuantity: bike.cartQuantity)
  }
  
  private func updateButtonState(stockQuantity: Int, cartQuantity: Int) {
    minusButton.isEnabled = cartQuantity > 1
    plusButton.isEnabled = cartQuantity < stockQuantity
  }
  
  
  
  @objc private func plusButtonTapped() {
    
    delegate?.plusButton(self)
  }
  
  @objc private func minusButtonTapped() {
    
    delegate?.minusButton(self)
  }
  
  @objc private func deleteButtonTapped() {
    if let indexPath = self.indexPath {
      delegate?.deleteButton(self, indexPath: indexPath)
    }
  }
  
  
  
  private func setupViews() {
    [checkButton, cartImage, vStackView, deleteProductButton].forEach(productCardView.addSubview)
    contentView.addSubview(productCardView)
    [minusButton, quantityLabel, plusButton].forEach { hStackView.addArrangedSubview($0) }
    [bikeNameLabel, bikePriceLabel, hStackView].forEach { vStackView.addArrangedSubview($0) }
    
  }
  
  private func layout() {
    
    checkButton.snp.makeConstraints {
      $0.left.equalToSuperview().offset(10)
      $0.top.equalToSuperview().offset(15)
    }
    
    cartImage.snp.makeConstraints {
      $0.left.equalTo(checkButton.snp.right).offset(12)
      $0.width.equalTo(75)
      $0.height.equalTo(89)
      $0.top.equalTo(checkButton.snp.top)
      $0.bottom.equalTo(productCardView.snp.bottom).offset(-10)
    }
    
    vStackView.snp.makeConstraints {
      $0.left.equalTo(cartImage.snp.right).offset(12)
      $0.top.equalTo(checkButton.snp.top)
      $0.bottom.equalTo(cartImage.snp.bottom)
    }
    
    productCardView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.bottom.equalToSuperview().offset(-10)
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }
    
    deleteProductButton.snp.makeConstraints {
      $0.bottom.equalTo(vStackView.snp.bottom)
      $0.right.equalToSuperview().offset(-10)
      $0.width.equalTo(16)
      $0.height.equalTo(16)
    }
  }
  
}
