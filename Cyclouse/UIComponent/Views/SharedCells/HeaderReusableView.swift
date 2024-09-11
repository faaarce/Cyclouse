//
//  HeaderReusableView.swift
//  Cyclouse
//
//  Created by yoga arie on 09/09/24.
//

import UIKit
import SnapKit

class HeaderReusableView: UICollectionReusableView {
      
  
   let headerLabel: UILabel = {
    LabelFactory.build(text: "All Bike Product", font: ThemeFont.semibold(ofSize: 14), textColor: .white)
  }()
  
  private let seeMoreButton: UIButton = {
    let object = UIButton()
    object.titleLabel?.font = ThemeFont.regular(ofSize: 12)
    object.setTitle("See More", for: .normal)
    object.setTitleColor(ThemeColor.primary, for: .normal)
    return object
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    layoutViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
    layoutViews()
  }
  
  private func setupViews() {
    [headerLabel, seeMoreButton].forEach(addSubview)
  }
  
  private func layoutViews(){
    headerLabel.snp.makeConstraints {
      $0.left.equalToSuperview().offset(25)
      $0.centerY.equalToSuperview()
    }
    
    seeMoreButton.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-25)
      $0.centerY.equalToSuperview()
    }
  }
  
}
