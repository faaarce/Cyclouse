//
//  DetailViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 11/09/24.
//
import SnapKit
import UIKit

class DetailViewController: UIViewController {
  
  var coordinator: DetailCoordinator
  
  private let detailImage: UIImageView = {
    let object = UIImageView(image: .init(named: "bike"))
    object.contentMode = .scaleToFill
    object.layer.masksToBounds = true
    object.layer.cornerRadius = 12
    return object
  }()
  
  private let firstImage: UIImageView = {
    let object = UIImageView(image: .init(named: "bike"))
    object.contentMode = .scaleToFill
    object.layer.masksToBounds = true
    object.layer.cornerRadius = 12
    return object
  }()
  
  private let secondImage: UIImageView = {
    let object = UIImageView(image: .init(named: "bike"))
    object.contentMode = .scaleToFill
    object.layer.masksToBounds = true
    object.layer.cornerRadius = 12
    return object
  }()
  
  private let thirdImage: UIImageView = {
    let object = UIImageView(image: .init(named: "bike"))
    object.contentMode = .scaleToFill
    object.layer.masksToBounds = true
    object.layer.cornerRadius = 12
    return object
  }()
  
  private let fourImage: UIImageView = {
    let object = UIImageView(image: .init(named: "bike"))
    object.contentMode = .scaleToFill
    object.layer.masksToBounds = true
    object.layer.cornerRadius = 12
    return object
  }()
  
  private lazy var hImageStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 10
    stack.alignment = .fill
    stack.distribution = .fillEqually
    return stack
  }()
  
  private let priceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.semibold(ofSize: 16), textColor: ThemeColor.primary)
  }()
  
  private let productTitleLabel: UILabel = {
    LabelFactory.build(text: "TDR 3.000 - Mountain Bike", font: ThemeFont.semibold(ofSize: 12), textColor: .white)
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 5
    label.font = ThemeFont.medium(ofSize: 12)
    label.textColor = ThemeColor.labelColorSecondary
    
    return label
  }()
  
  private var fullDescription: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat, Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequatit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Detail"
    view.backgroundColor = ThemeColor.background
    setupViews()
    layout()
    setupDescriptionLabel()
  }
  
  init(coordinator: DetailCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews(){
    [firstImage, secondImage, thirdImage, fourImage].forEach {
      hImageStackView.addArrangedSubview($0)
    }
    view.addSubview(hImageStackView)
    view.addSubview(detailImage)
    view.addSubview(priceLabel)
    view.addSubview(productTitleLabel)
    view.addSubview(descriptionLabel)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(descriptionLabelTapped))
    descriptionLabel.addGestureRecognizer(tapGesture)
    descriptionLabel.isUserInteractionEnabled = true
  }
  
  func setupDescriptionLabel() {
    descriptionLabel.appendReadmore(after: fullDescription, trailingContent: .readmore)
  }
  
  @objc func descriptionLabelTapped() {
    if descriptionLabel.numberOfLines == 4 {
      descriptionLabel.appendReadLess(after: fullDescription, trailingContent: .readless)
    } else {
      descriptionLabel.appendReadmore(after: fullDescription, trailingContent: .readmore)
    }
  }
  
  func layout() {
    detailImage.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
      $0.height.equalTo(292)
    }
    
    
    hImageStackView.snp.makeConstraints {
      $0.top.equalTo(detailImage.snp.bottom).offset(25)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.height.equalTo(70)
    }
    
    priceLabel.snp.makeConstraints {
      $0.top.equalTo(hImageStackView.snp.bottom).offset(25)
      $0.left.equalToSuperview().offset(20)
    }
    
    productTitleLabel.snp.makeConstraints {
      $0.top.equalTo(priceLabel.snp.bottom).offset(8)
      $0.left.equalToSuperview().offset(20)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(productTitleLabel.snp.bottom).offset(8)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
  }
  
}
