//
//  ProfileViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//

import UIKit

class ProfileViewController: UIViewController {
  
  var coordinator: ProfileCoordinator
  
  private lazy var mainStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 0
    stack.alignment = .fill
    stack.distribution = .fillProportionally
    return stack
  }()
  
  private let profileImageView: UIImageView = {
    let object = UIImageView(image: .init(systemName: "person.fill"))
    object.layer.cornerRadius = 50
    object.layer.masksToBounds = true
    object.layer.borderWidth = 3
    object.layer.borderColor = UIColor(hex: "#555555").cgColor
    object.backgroundColor = ThemeColor.cardFillColor
    return object
  }()
    
  private let cameraButton: UIButton = {
    let object = UIButton(type: .system)
    object.setTitle(nil, for: .normal)
    object.setImage(UIImage(systemName: "camera")?.withRenderingMode(.alwaysTemplate), for: .normal)
    object.tintColor = ThemeColor.primary
    object.layer.cornerRadius = 15
    object.layer.masksToBounds = true
    return object
  }()
  
  private lazy var profileView: UIView = {
    let object = UIView(frame: .zero)
    object.backgroundColor = ThemeColor.cardFillColor
    object.layer.cornerRadius = 12
    return object
  }()
  
  private let profileName: UILabel = {
    LabelFactory.build(text: "Faris", font: ThemeFont.semibold(ofSize: 14), textColor: .white)
  }()
  
  private let profileEmail: UILabel = {
    LabelFactory.build(text: "faris@gmail.com", font: ThemeFont.medium(ofSize: 10), textColor: ThemeColor.labelColorSecondary)
  }()
  
  private lazy var menuItems: [UIView] = [
    createPaddedMenuItemStack(title: "My Account", icon: "person"),
    createDivider(),
    createPaddedMenuItemStack(title: "Transaction History", icon: "clock.arrow.circlepath"),
    createDivider(),
    createPaddedMenuItemStack(title: "Language", icon: "globe"),
    createDivider(),
    createPaddedMenuItemStack(title: "Help Center", icon: "questionmark.circle")
  ]
  init(coordinator: ProfileCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    layout()
  }
  
  private func setupViews() {
    view.backgroundColor = ThemeColor.background
    [profileImageView, cameraButton, profileView, mainStackView, profileName, profileEmail].forEach(view.addSubview)
    view.sendSubviewToBack(profileView)
   
    menuItems.forEach { mainStackView.addArrangedSubview($0) }
  }
  
  private func layout() {
    
    profileImageView.snp.makeConstraints {
      $0.width.equalTo(100)
      $0.height.equalTo(100)
      $0.centerX.equalToSuperview()
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
    }
    
    cameraButton.snp.makeConstraints {
      $0.width.equalTo(30)
      $0.height.equalTo(30)
      $0.right.equalTo(profileImageView.snp.right)
      $0.bottom.equalTo(profileImageView.snp.bottom)
    }
    
    profileView.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.top.equalTo(profileImageView.snp.centerY)
      $0.bottom.equalTo(mainStackView.snp.top).offset(-30)
    }
    
    profileName.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(10)
      $0.centerX.equalToSuperview()
     
    }
    
    profileEmail.snp.makeConstraints {
      $0.top.equalTo(profileName.snp.bottom).offset(5)
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(profileView.snp.bottom).offset(-20)
    }
    
    mainStackView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.centerY.equalToSuperview()
    }
  }
  
  private func createMenuItemStack(title: String, icon: String) -> UIStackView {
    let label = LabelFactory.build(text: title, font: ThemeFont.medium(ofSize: 16), textColor: .white)
     
    let iconImageView = UIImageView(image: UIImage(systemName: icon))
    iconImageView.contentMode = .scaleAspectFit
    iconImageView.tintColor = ThemeColor.primary
    iconImageView.snp.makeConstraints {
      $0.width.height.equalTo(24)
    }
     
    let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    arrowImageView.contentMode = .scaleAspectFit
    arrowImageView.tintColor = .tertiaryLabel
    arrowImageView.snp.makeConstraints {
      $0.width.height.equalTo(24)
    }
     
    let spacerView = UIView()
    spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
     
    let stack = UIStackView(arrangedSubviews: [iconImageView, label, spacerView, arrowImageView])
    stack.axis = .horizontal
    stack.spacing = 16
    stack.alignment = .center
    stack.distribution = .fill
     
    iconImageView.setContentHuggingPriority(.required, for: .horizontal)
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    arrowImageView.setContentHuggingPriority(.required, for: .horizontal)
     
    return stack
  }
  
  private func createPaddedMenuItemStack(title: String, icon: String) -> UIStackView {
    let menuStack = createMenuItemStack(title: title, icon: icon)
    let paddingStack = UIStackView(arrangedSubviews: [menuStack])
    paddingStack.axis = .vertical
    paddingStack.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    paddingStack.isLayoutMarginsRelativeArrangement = true
    return paddingStack
  }
  
  private func createDivider() -> UIView {
    let divider = UIView()
    divider.backgroundColor = ThemeColor.cardFillColor
    divider.snp.makeConstraints {
      $0.height.equalTo(1)
    }
    return divider
  }
}
