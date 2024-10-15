//
//  CategoryViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 09/09/24.
//

import UIKit
import SkeletonView

class CategoryViewCell: UICollectionViewCell {
  
  private let categoryLabel: UILabel = {
    LabelFactory.build(text: "All", font: ThemeFont.semibold(ofSize: 12), textColor: ThemeColor.black)
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    layout()
    setupSkeletonView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setupViews()
    layout()
    setupSkeletonView()
  }
  
  private func setupSkeletonView() {
    isSkeletonable = true
    contentView.isSkeletonable = true
    categoryLabel.isSkeletonable = true
    
    categoryLabel.linesCornerRadius = 8
  }
  
  private func setupViews() {
    backgroundColor = ThemeColor.primary
    layer.cornerRadius = 10
    contentView.addSubview(categoryLabel)
  }
  
  private func layout() {
    categoryLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalToSuperview()
    }
  }
  
  func configure(with category: String) {
    categoryLabel.text = category
  }
  
}
