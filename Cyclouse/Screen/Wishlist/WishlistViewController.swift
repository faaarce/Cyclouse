//
//  WishlistViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 06/09/24.
//
import SnapKit
import UIKit

class WishlistViewController: UIViewController {
  
  var coordinator: WishlistCoordinator

  
  private let checkButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
    object.tintColor = .white
    object.contentMode = .scaleAspectFit
    return object
  }()
  
  private let cartImage: UIImageView = {
    let view = UIImageView(image: .init(named: "onthel"))
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  private let bikeNameLabel: UILabel = {
    LabelFactory.build(text: "TDR 3.000 - Mountain Bike", font: ThemeFont.semibold(ofSize: 16), textColor: .white)
  }()
  
  private let bikePriceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.bold(ofSize: 16), textColor: ThemeColor.primary)
  }()
  
  private let plusButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "plus.app"), for: .normal)
    object.contentMode = .scaleAspectFit
    return object
  }()
  
  private let minusButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "minus.square"), for: .normal)
    object.contentMode = .scaleAspectFit
    return object
  }()
  
  private let quantityLabel: UILabel = {
    LabelFactory.build(text: "1", font: ThemeFont.semibold(ofSize: 14), textColor: .white)
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
  
  init(coordinator: WishlistCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = ThemeColor.background
    setupViews()
    layout()
    }
  
  func setupViews() {

    view.addSubview(productCardView)
   
    [minusButton, quantityLabel, plusButton].forEach { hStackView.addArrangedSubview($0) }
    [bikeNameLabel, bikePriceLabel, hStackView].forEach { vStackView.addArrangedSubview($0) }
    [checkButton, cartImage, vStackView].forEach(productCardView.addSubview)
  }
  
  func layout() {

    
    checkButton.snp.makeConstraints {
      $0.left.equalToSuperview().offset(10)
      $0.top.equalToSuperview().offset(15)
    }
    
    cartImage.snp.makeConstraints {
      $0.left.equalTo(checkButton.snp.right).offset(12)
      $0.width.equalTo(75)
      $0.height.equalTo(89)
      $0.top.equalTo(checkButton.snp.top)
    }
    
    vStackView.snp.makeConstraints {
      $0.left.equalTo(cartImage.snp.right).offset(12)
      $0.top.equalTo(checkButton.snp.top)
    }
    
    productCardView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.width.equalTo(310)
      $0.height.equalTo(119)
    }
  }
  
}


