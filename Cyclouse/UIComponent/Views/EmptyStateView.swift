//
//  EmptyStateView.swift
//  Cyclouse
//
//  Created by yoga arie on 03/10/24.
//

import Foundation
import UIKit
import SnapKit

protocol EmptyStateViewDelegate: AnyObject {
  func tapButton()
}

class EmptyStateView: UIView {
  
  weak var delegate: EmptyStateViewDelegate?
  
  private let imgView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let descLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var tapButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(actionTap), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Initializer
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    layout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    addSubview(imgView)
    addSubview(descLabel)
    addSubview(tapButton)
  }
  
  private func layout() {
    imgView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
      make.height.equalTo(200)
    }
    
    descLabel.snp.makeConstraints { make in
      make.top.equalTo(imgView.snp.bottom).offset(20)
      make.centerX.equalToSuperview()
    }
    
    tapButton.snp.makeConstraints { make in
      make.top.equalTo(descLabel.snp.bottom).offset(15)
      make.height.equalTo(15)
      make.centerX.equalToSuperview()
    }
  }
  
  @objc private func actionTap() {
    delegate?.tapButton()
  }
  
  // MARK: - Public methods to configure the view
  func configure(image: UIImage?, description: String, buttonTitle: String) {
    imgView.image = image
    descLabel.text = description
    tapButton.setTitle(buttonTitle, for: .normal)
  }
}
