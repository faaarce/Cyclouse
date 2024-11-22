//
//  EmptyStateView.swift
//  Cyclouse
//
//  Created by yoga arie on 03/10/24.
//

import Foundation
import UIKit
import SnapKit
import Lottie

protocol EmptyStateViewDelegate: AnyObject {
  func tapButton()
}

class EmptyStateView: UIView {
  
  weak var delegate: EmptyStateViewDelegate?
  
  private let animationView: LottieAnimationView = {
    let animationView = LottieAnimationView()
    animationView.contentMode = .scaleAspectFit
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.loopMode = .loop // Loop the animation if desired
    return animationView
  }()
  

  private let descLabel: UILabel = {
    LabelFactory.build(text: "Test", font: ThemeFont.medium(ofSize: 16), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private lazy var tapButton: UIButton = {
    let button = ButtonFactory.build(title: "Test", font: ThemeFont.bold(ofSize: 18), radius: 12)
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
    addSubview(animationView)

    addSubview(descLabel)
    addSubview(tapButton)
  }
  
  
    
  
  private func layout() {
    animationView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
      make.height.equalTo(200)
    }
    
    descLabel.snp.makeConstraints { make in
      make.top.equalTo(animationView.snp.bottom).offset(20)
      make.centerX.equalToSuperview()
    }
    
    tapButton.snp.makeConstraints { make in
      make.top.equalTo(descLabel.snp.bottom).offset(15)
      make.height.equalTo(50)
      make.width.equalTo(200)
      make.centerX.equalToSuperview()
    }
  }
  
  @objc private func actionTap() {
    delegate?.tapButton()
  }
  
  // MARK: - Public methods to configure the view
  func configure(animationName: String, description: String, buttonTitle: String) {
    let animation = LottieAnimation.named(animationName)
         animationView.animation = animation
         animationView.play()
         descLabel.text = description
         tapButton.setTitle(buttonTitle, for: .normal)
     }
}
