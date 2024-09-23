//
//  HistoryTableViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 23/09/24.
//
import SnapKit
import UIKit

class HistoryTableViewCell: UITableViewCell {
  
  private let productBikeImage: UIImageView = {
    let view = UIImageView(image: .init(named: "onthel"))
    view.contentMode = .scaleToFill
    return view
  }()
  
  private let productNameLabel: UILabel = {
    LabelFactory.build(text: "Mountain Bike", font: ThemeFont.semibold(ofSize: 12), textColor: .white)
  }()
  
  private let priceLabel: UILabel = {
    LabelFactory.build(text: "Rp 1,000,000", font: ThemeFont.semibold(ofSize: 12), textColor: .white)
  }()
  
  private let categoryLabel: UILabel = {
    LabelFactory.build(text: "Wheelset", font: ThemeFont.regular(ofSize: 10), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private let totalPriceLabel: UILabel = {
    LabelFactory.build(text: "Rp 1.000.000", font: ThemeFont.semibold(ofSize: 12), textColor: .white)
  }()
  
  private let productCardView: UIView = {
    let object = UIView(frame: .zero)
    object.backgroundColor = ThemeColor.cardFillColor
    object.layer.cornerRadius = 10
    object.layer.masksToBounds = true
    return object
  }()
  
  private let vStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 10
    stack.alignment = .leading
    stack.distribution = .fillEqually
    return stack
  }()
  
  private let quantityLabel: UILabel = {
    LabelFactory.build(text: "Total 1 Product", font: ThemeFont.semibold(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
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
  
  private func layout() {
    productCardView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.bottom.equalToSuperview().offset(-10)
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }
    
    productBikeImage.snp.makeConstraints {
      $0.width.equalTo(75)
      $0.height.equalTo(56)
      $0.top.equalToSuperview().offset(16)
      $0.left.equalToSuperview().offset(10)
      
    }
    
    vStackView.snp.makeConstraints {
      $0.top.equalTo(productBikeImage.snp.top)
      $0.left.equalTo(productBikeImage.snp.right).offset(12)
      $0.bottom.equalTo(productBikeImage.snp.bottom)
    }
    
    totalPriceLabel.snp.makeConstraints {
      $0.top.equalTo(vStackView.snp.bottom).offset(15)
      $0.right.equalToSuperview().offset(-20)
      $0.bottom.equalToSuperview().offset(-10)
    }
    
    quantityLabel.snp.makeConstraints {
      $0.top.equalTo(productBikeImage.snp.bottom).offset(15)
      $0.left.equalToSuperview().offset(10)
    }
    
    
  }
  
  
  private func setupViews() {
    [productNameLabel, categoryLabel, priceLabel].forEach(vStackView.addArrangedSubview)
    [productBikeImage,vStackView, totalPriceLabel, quantityLabel].forEach(productCardView.addSubview)
    contentView.addSubview(productCardView)
  }
}
