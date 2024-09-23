//
//  OnboardingViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController {
  
  var coordinator: OnboardingCoordinator
  
  private let backgroundImage: UIImageView = {
    let view = UIImageView(image: .init(named: "onboarding"))
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  private let topLabel: UILabel = {
    LabelFactory.build(
      text: "Ride into a Healthier, Happier You!",
      font: ThemeFont.extraBold(ofSize: 24),
      textAlignment: .left)
  }()
  
  private let bottomLabel: UILabel = {
    LabelFactory.build(
      text: "Buy Your Favorite Bike with Attractive Discounts",
      font: ThemeFont.regular(ofSize: 16),
      textAlignment: .left)
  }()
  
  private lazy var startedButton: UIButton = {
    let button = ButtonFactory.build(
      title: "Get Started",
      font: ThemeFont.semibold(ofSize: 14)
    )
    return button
  }()
  
  init(coordinator: OnboardingCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    layout()
  }
  
  private func layout() {
    self.view.addSubview(backgroundImage)
    backgroundImage.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    self.view.addSubview(startedButton)
    startedButton.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
      $0.left.equalToSuperview().offset(25)
      $0.right.equalToSuperview().offset(-25)
      $0.height.equalTo(50)
    }
    
    self.view.addSubview(bottomLabel)
    bottomLabel.snp.makeConstraints {
      $0.bottom.equalTo(startedButton.snp.top).offset(-40)
      $0.left.equalToSuperview().offset(25)
      $0.right.equalToSuperview().offset(-25)
    }
    
    self.view.addSubview(topLabel)
    topLabel.snp.makeConstraints {
      $0.bottom.equalTo(bottomLabel.snp.top).offset(-8)
      $0.left.equalToSuperview().offset(25)
      $0.right.equalToSuperview().offset(-25)
    }
  }
  
}
