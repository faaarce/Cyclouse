//
//  BikeProductViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 08/09/24.
//
import SkeletonView
import UIKit

class BikeProductViewCell: UICollectionViewCell {
  
  private let productImage: UIImageView = {
    let object = UIImageView(image: .init(named: "banner"))
    object.contentMode = .scaleToFill
    return object
  }()
  
  private let productLabel: UILabel = {
    LabelFactory.build(text: "Fixie FullBike Jayjo", font: ThemeFont.semibold(ofSize: 12), textColor: .white)
  }()
  
  private let categoryLabel: UILabel = {
    LabelFactory.build(text: "Fullbike", font: ThemeFont.bold(ofSize: 10), textColor: ThemeColor.primary)
  }()
  
  private let bikeSoldQuantityLabel: UILabel = {
    LabelFactory.build(text: "1,5RB Sold", font: ThemeFont.medium(ofSize: 10), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let priceLabel: UILabel = {
    LabelFactory.build(text: "Rp 2,500,000", font: ThemeFont.bold(ofSize: 12), textColor: ThemeColor.primary)
  }()
  
  
  private lazy var vStackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [productLabel, categoryLabel, bikeSoldQuantityLabel ,priceLabel])
    view.axis = .vertical
    view.spacing = 4
    view.distribution = .fill
    view.alignment = .leading
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)

    setupViews()
    layout()
    setupSkeletonView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupSkeletonView()
  }
  
  func setupSkeletonView(){
    isSkeletonable = true
    contentView.isSkeletonable = true
    vStackView.isSkeletonable = true
    productImage.isSkeletonable = true
    productLabel.isSkeletonable = true
    categoryLabel.isSkeletonable = true
    priceLabel.isSkeletonable = true
    bikeSoldQuantityLabel.isSkeletonable = true
    [productLabel, categoryLabel, bikeSoldQuantityLabel, priceLabel].forEach { view in
      view?.linesCornerRadius = 8 
    }
  }
  
  func configure(with product: Product) {
    productLabel.text = product.name
    priceLabel.text = product.price.toRupiah()
    categoryLabel.text = product.brand
    bikeSoldQuantityLabel.text = "\(product.quantity)"
  }
  
  private func setupViews() {
    backgroundColor = ThemeColor.cardFillColor
    layer.cornerRadius = 8
    [productImage, vStackView].forEach(contentView.addSubview)
  }
  
  private func layout() {
    productImage.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(0)
      make.height.equalToSuperview().multipliedBy(0.6)
    }
    
    vStackView.snp.makeConstraints { make in
      make.top.equalTo(productImage.snp.bottom).offset(4)
      make.leading.equalToSuperview().offset(10)
      make.trailing.equalToSuperview()
    }
  }
}

