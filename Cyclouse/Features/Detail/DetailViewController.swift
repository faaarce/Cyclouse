//
//  DetailViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 11/09/24.
//
import SnapKit
import UIKit
import Combine
import SwiftMessages
import Hero

class DetailViewController: UIViewController {
  
  // MARK: - Properties
  private let viewModel: DetailViewModel
  private var coordinator: DetailCoordinator
  private var cancellables = Set<AnyCancellable>()
  
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
  
  private let addToCartButton: UIButton = {
    let object = UIButton(type: .custom)
    object.backgroundColor = ThemeColor.cardFillColor
    object.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
    object.tintColor = ThemeColor.primary
    object.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    return object
  }()
  
  private let buyNowButton: UIButton = {
    let button = ButtonFactory.build(title: "Buy Now", font: ThemeFont.medium(ofSize: 12), radius: 0.0)
    button.addTarget(self, action: #selector(buyNowButtonTapped), for: .touchUpInside)
    return button
  }()
  
  
  private let hButtonStackView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal
    view.spacing = 0
    view.distribution = .fillEqually
    view.alignment = .fill
    
    return view
  }()
  
  private let priceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.semibold(ofSize: 16), textColor: ThemeColor.primary)
  }()
  
  private let productTitleLabel: UILabel = {
    LabelFactory.build(text: "TDR 3.000 - Mountain Bike", font: ThemeFont.semibold(ofSize: 12), textColor: .white)
  }()
  
  private let descriptionTextView: ReadMoreTextView = {
    let textView = ReadMoreTextView()
    textView.font = ThemeFont.medium(ofSize: 12)
    textView.textColor = ThemeColor.labelColorSecondary
    textView.backgroundColor = .clear
    textView.isScrollEnabled = false
    textView.maximumNumberOfLines = 5
    textView.shouldTrim = true
    let readMoreAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: ThemeColor.primary,
      .font: ThemeFont.medium(ofSize: 12)
    ]
    let readLessAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: ThemeColor.primary,
      .font: ThemeFont.medium(ofSize: 12)
    ]
    
    textView.attributedReadMoreText = NSAttributedString(string: "... Read More", attributes: readMoreAttributes)
    textView.attributedReadLessText = NSAttributedString(string: "Read Less", attributes: readLessAttributes)
    
    return textView
  }()
  
  
  private var fullDescription: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Detail"
    view.backgroundColor = ThemeColor.background
    setupViews()
    layout()
    configureDescriptionTextView()
    bind()
    configureViews()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.viewModel.isLoading = false
      
    }
  }
  
  init(coordinator: DetailCoordinator, viewModel: DetailViewModel) {
    self.coordinator = coordinator
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private Methods
  private func bind() {
    viewModel.$isLoading
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isLoading in
        if isLoading {
          // self?.configureSkeleton()
        } else {
          // self?.hideSkeleton()
        }
      }
      .store(in: &cancellables)
    
    viewModel.$showError
      .receive(on: DispatchQueue.main)
      .compactMap { $0 }
      .sink { [weak self] error in
        MessageAlert.showError(
                     title: error.title,
                     message: error.message
                 )
      }
      .store(in: &cancellables)
    
    viewModel.$showSuccess
      .receive(on: DispatchQueue.main)
      .compactMap { $0 }
      .sink { [weak self] success in
        MessageAlert.show(
                     title: success.title,
                     message: success.message,
                     theme: .success,
                     presentationStyle: .top
                 )
      }
      .store(in: &cancellables)
  }
  
  private func showMessage(title: String, body: String, theme: Theme, backgroundColor: UIColor? = nil, foregroundColor: UIColor? = nil) {
    let view = MessageView.viewFromNib(layout: .cardView)
    view.configureTheme(theme)
    view.configureDropShadow()
    
    if let backgroundColor = backgroundColor {
      view.backgroundColor = backgroundColor
    }
    
    if let foregroundColor = foregroundColor {
      view.titleLabel?.textColor = foregroundColor
      view.bodyLabel?.textColor = foregroundColor
    }
    
    view.configureContent(title: title, body: body)
    view.button?.isHidden = true
    
    var config = SwiftMessages.Config()
    config.presentationStyle = .top
    config.duration = .seconds(seconds: 3)
    config.dimMode = .gray(interactive: true)
    config.interactiveHide = true
    
    SwiftMessages.show(config: config, view: view)
  }
  
  private func configureSkeleton() {
    // Make views skeletonable
    detailImage.isSkeletonable = true
    firstImage.isSkeletonable = true
    secondImage.isSkeletonable = true
    thirdImage.isSkeletonable = true
    fourImage.isSkeletonable = true
    priceLabel.isSkeletonable = true
    productTitleLabel.isSkeletonable = true
    descriptionTextView.isSkeletonable = true
    hImageStackView.isSkeletonable = true
    // Configure text views for skeleton
    priceLabel.linesCornerRadius = 8
    productTitleLabel.linesCornerRadius = 8
    //    descriptionTextView.skeletonTextLineHeight = .fixed(5)
    descriptionTextView.skeletonTextNumberOfLines = 1
    
    // Show skeleton
    view.isSkeletonable = true
    view.showAnimatedGradientSkeleton()
  }
  
  @objc private func addToCartButtonTapped(_ sender: UIButton) {
    viewModel.addToCart()
  }
  
  private func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  @objc func buyNowButtonTapped(_ sender: UIButton) {
    let vc = PopUpViewController()
    vc.modalPresentationStyle = .pageSheet
    self.present(vc, animated: true) {
      vc.view.becomeFirstResponder()
    }
  }
  
  private func hideSkeleton() {
    view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
  }
  
  private func configureViews() {
    productTitleLabel.text = viewModel.productName
    descriptionTextView.text = viewModel.productDescription
    priceLabel.text = viewModel.productPrice
    
    viewModel.productImages.forEach { imageUrl in
      [detailImage, firstImage, secondImage, thirdImage, fourImage].forEach { display in
        display.kf.setImage(with: URL(string: imageUrl))
      }
    }
    
    detailImage.heroID = "productImage_\(viewModel.productId)"
    productTitleLabel.heroID = "productLabel_\(viewModel.productId)"
    priceLabel.heroID = "priceLabel_\(viewModel.productId)"
  }
  
  func setupViews() {
    [firstImage, secondImage, thirdImage, fourImage].forEach {
      hImageStackView.addArrangedSubview($0)
    }
    [addToCartButton, buyNowButton].forEach { hButtonStackView.addArrangedSubview($0) }
    
    [hImageStackView, detailImage, priceLabel, productTitleLabel, descriptionTextView, hButtonStackView].forEach {
      view.addSubview($0)
      
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
    
    descriptionTextView.snp.makeConstraints {
      $0.top.equalTo(productTitleLabel.snp.bottom).offset(8)
      $0.left.equalToSuperview().offset(16)
      $0.right.equalToSuperview().offset(-16)
    }
    
    hButtonStackView.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.height.equalTo(75)
      $0.bottom.equalToSuperview()
    }
    
  }
  
  func configureDescriptionTextView() {
    descriptionTextView.text = fullDescription
    
    // Handle size changes
    descriptionTextView.onSizeChange = { [weak self] _ in
      self?.view.layoutIfNeeded()
    }
  }
  
}
/*  with Add to cart API
 let productId = product.id
 
 cartService.addToCart(productId: productId, quantity: 1)
 .receive(on: DispatchQueue.main)
 .sink { [weak self] completion in
 switch completion {
 case .finished:
 break
 
 case .failure(let error):
 if let apiError = error as? APIError {
 print("API Error: \(apiError.localizedDescription)")
 } else {
 print("Unknown error: \(error.localizedDescription)")
 }
 }
 } receiveValue: { [weak self] response in
 self?.showAlert(title: "Success", message: "Added to cart: \(response.value.message)")
 }
 .store(in: &cancellables)
 */

