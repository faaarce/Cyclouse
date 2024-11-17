//
//  CartViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//
import Kingfisher
import UIKit

protocol CartCellDelegate: AnyObject {
  func minusButton(_ cell: CartViewCell)
  func plusButton(_ cell: CartViewCell)
  func deleteButton(_ cell: CartViewCell)
  func checkProduct(_ cell: CartViewCell, isChecked: Bool)
}

class CartViewCell: UITableViewCell {
  
  weak var delegate: CartCellDelegate?
  var bike: BikeDatabase?
  var indexPath: IndexPath?
  var isChecked: Bool = true
  
  
  private let checkButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
    object.tintColor = ThemeColor.primary
    object.contentMode = .scaleToFill
    object.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    return object
  }()
  
  private let cartImage: UIImageView = {
    let view = UIImageView(image: .init(named: "onthel"))
    view.contentMode = .scaleAspectFit
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
  
  func configure(with bike: BikeDatabase, isChecked: Bool) {
    self.bike = bike
    bikeNameLabel.text = bike.name
    bikePriceLabel.text = bike.price.toRupiah()
    quantityLabel.text = "\(bike.cartQuantity)"
    cartImage.kf.setImage(with: URL(string: bike.images.first ?? "https://i.imgur.com/DXv1ptr.jpeg"))
    self.isChecked = isChecked
    updateButtonState(stockQuantity: bike.stockQuantity, cartQuantity: bike.cartQuantity)
    updateCheckButtonAppearance()
  }
  
  func updateQuantityLabel(_ newQuantity: Int) {
         quantityLabel.text = "\(newQuantity)"
     }

     // Update button state method
     func updateButtonState(stockQuantity: Int, cartQuantity: Int) {
         minusButton.isEnabled = cartQuantity > 1
         plusButton.isEnabled = cartQuantity < stockQuantity
     }
  

  
  private func updateCheckButtonAppearance(){
    let imageName = isChecked ? "checkmark.square.fill" : "square"
          checkButton.setImage(UIImage(systemName: imageName), for: .normal)
  }
  
  
  @objc private func plusButtonTapped() {
    
    delegate?.plusButton(self)
  }
  
  @objc private func minusButtonTapped() {
    
    delegate?.minusButton(self)
  }
  
  @objc private func deleteButtonTapped() {

      delegate?.deleteButton(self)
    
  }
  
  @objc private func checkButtonTapped() {
    isChecked.toggle()
    updateCheckButtonAppearance()
    delegate?.checkProduct(self, isChecked: isChecked)
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
