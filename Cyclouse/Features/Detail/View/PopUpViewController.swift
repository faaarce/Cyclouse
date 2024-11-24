//
//  PopUpViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 14/09/24.
//
import SnapKit
import UIKit

protocol PopUpViewControllerDelegate: AnyObject {
    func popUpViewController(_ controller: PopUpViewController, didSelectBuyNow bikes: [BikeDatabase])
}

class PopUpViewController: UIViewController {
  
  // MARK: - Properties
  private var product: Product
  private var quantity: Int = 1
  weak var delegate: PopUpViewControllerDelegate?
  
  private let productNameLabel: UILabel = {
    LabelFactory.build(text: "Mountain Bike", font: ThemeFont.semibold(ofSize: 16))
  }()
  
  private let priceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.semibold(ofSize: 16), textColor: ThemeColor.primary)
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 16
    view.clipsToBounds = true
    view.backgroundColor = ThemeColor.background
    return view
  }()
  
  private let testTextField: UITextField = {
    let object = UITextField(frame: .zero)
    object.placeholder = "Test"
    object.textColor = .red
    return object
  }()
  
  private let maxDimmedAlpha: CGFloat = 0.6
  private lazy var dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.alpha = maxDimmedAlpha
    return view
  }()
  
  private let detailImage: UIImageView = {
    let object = UIImageView(image: .init(named: "onthel"))
    object.contentMode = .scaleToFill
    object.layer.cornerRadius = 12
    return object
  }()
  
  private let closeButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "xmark"), for: .normal)
    object.tintColor = ThemeColor.labelColorSecondary
    object.contentMode = .scaleAspectFit
    object.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    return object
  }()
  
  private let addToCart: UIButton = {
    let object = ButtonFactory.build(title: "Buy Now", font: ThemeFont.medium(ofSize: 12), radius: 12)
    object.addTarget(self, action: #selector(closeController), for: .touchUpInside)
    return object
  }()
  
  private let dividerView: UIView = {
    let object = UIView()
    object.backgroundColor = ThemeColor.cardFillColor
    return object
  }()
  
  private let plusButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "plus.app"), for: .normal)
    object.tintColor = ThemeColor.primary
    object.contentMode = .scaleAspectFit
    return object
  }()
  
  private let minusButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "minus.square"), for: .normal)
    object.tintColor = ThemeColor.primary
    object.contentMode = .scaleAspectFit
    return object
  }()
  
  private let quantityLabel: UILabel = {
    LabelFactory.build(text: "1", font: ThemeFont.semibold(ofSize: 14), textColor: .white)
  }()
  
  private let hStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 10
    stack.alignment = .fill
    stack.distribution = .fillEqually
    return stack
  }()
  
  private let totalLabel: UILabel = {
    LabelFactory.build(text: "Jumlah", font: ThemeFont.semibold(ofSize: 14))
  }()
  
  private let defaultHeight: CGFloat = 300
  
  init(product: Product) {
      self.product = product
      super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupConstraints()
    configureWithProduct()
    setupActions()
    view.isUserInteractionEnabled = true
    containerView.isUserInteractionEnabled = true
    closeButton.isUserInteractionEnabled = true
    testTextField.isUserInteractionEnabled = true
  }
  
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    animateContainerHeight()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateContainerHeight()
    self.view.becomeFirstResponder()
  }
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  
     @objc private func incrementQuantity() {
         quantity += 1
         quantityLabel.text = "\(quantity)"
         updateTotalPrice()
     }
     
     @objc private func decrementQuantity() {
         guard quantity > 1 else { return }
         quantity -= 1
         quantityLabel.text = "\(quantity)"
         updateTotalPrice()
     }
  
  private func setupActions() {
        plusButton.addTarget(self, action: #selector(incrementQuantity), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(decrementQuantity), for: .touchUpInside)
        addToCart.addTarget(self, action: #selector(buyNowTapped), for: .touchUpInside)
    }
  
  @objc private func buyNowTapped() {
         let bike = BikeDatabase(
             name: product.name,
             price: product.price,
             brand: product.brand,
             images: product.images,
             descriptions: product.description,
             stockQuantity: quantity,
             productId: product.id
         )
         
         delegate?.popUpViewController(self, didSelectBuyNow: [bike])
         dismiss(animated: true)
     }
  
  private func updateTotalPrice() {
         let totalPrice = Double(product.price) * Double(quantity)
         priceLabel.text = totalPrice.toRupiah()
     }
  
  private func configureWithProduct() {
         productNameLabel.text = product.name
         priceLabel.text = product.price.toRupiah()
         detailImage.kf.setImage(with: URL(string: product.images.first ?? ""))
         updateTotalPrice()
     }
  
  
  @objc private func closeButtonTapped() {
    print("Close button tapped")
    closeController()
  }
  
  @objc private func closeController() {
    print("test")
    self.dismiss(animated: true)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    print("Touch began in PopUpViewController")
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    print("Touch ended in PopUpViewController")
  }
  
  
  
  private func setupView() {
    view.backgroundColor = .clear
    view.addSubview(dimmedView)
    view.addSubview(containerView)
    containerView.addSubview(hStackView)
    containerView.addSubview(productNameLabel)
    containerView.addSubview(priceLabel)
    containerView.addSubview(closeButton)
    containerView.addSubview(addToCart)
    containerView.addSubview(detailImage)
    containerView.addSubview(dividerView)
    containerView.addSubview(totalLabel)
    containerView.addSubview(testTextField)
    [minusButton, quantityLabel, plusButton].forEach { hStackView.addArrangedSubview($0) }
  }
  
  private func setupConstraints() {
    dimmedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(defaultHeight)
      make.bottom.equalToSuperview().offset(defaultHeight)
    }
    
    priceLabel.snp.makeConstraints { make in
      make.top.equalTo(productNameLabel.snp.bottom).offset(8)
      make.left.equalTo(detailImage.snp.right).offset(15)
    }
    
    closeButton.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-20)
      $0.top.equalToSuperview().offset(20)
      $0.height.equalTo(24)
      $0.width.equalTo(24)
    }
    
    addToCart.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
      $0.height.equalTo(36)
    }
    
    detailImage.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.top.equalToSuperview().offset(20)
      $0.width.equalTo(94)
      $0.height.equalTo(94)
    }
    
    productNameLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.left.equalTo(detailImage.snp.right).offset(15)
    }
    
    dividerView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.top.equalTo(detailImage.snp.bottom).offset(12)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
    }
    
    testTextField.snp.makeConstraints { make in
      make.top.equalTo(detailImage.snp.bottom).offset(20)
    }
    
    hStackView.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-20)
      $0.bottom.equalTo(addToCart.snp.top).offset(-12)
    }
    
    totalLabel.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.bottom.equalTo(addToCart.snp.top).offset(-12)
    }
  }
  
  private func animateContainerHeight() {
    UIView.animate(withDuration: 0.3) {
      self.containerView.snp.updateConstraints { make in
        make.bottom.equalToSuperview()
      }
      self.view.layoutIfNeeded()
    }
  }
}
