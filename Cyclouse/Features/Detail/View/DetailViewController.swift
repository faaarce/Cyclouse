//
//  DetailViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 11/09/24.
//
import SnapKit
import UIKit
import Combine
import EasyNotificationBadge

import Hero

class DetailViewController: BaseViewController, ViewModelBindable, PopUpViewControllerDelegate {

    // MARK: - Properties

    typealias ViewModel = DetailViewModel
    var viewModel: DetailViewModel
    var coordinator: DetailCoordinator
  private let service = DatabaseService.shared
  

    private let detailImage: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleToFill
        object.layer.masksToBounds = true
        object.layer.cornerRadius = 12
        return object
    }()

    private let firstImage: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleToFill
        object.layer.masksToBounds = true
        object.layer.cornerRadius = 12
        return object
    }()

    private let secondImage: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleToFill
        object.layer.masksToBounds = true
        object.layer.cornerRadius = 12
        return object
    }()

    private let thirdImage: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleToFill
        object.layer.masksToBounds = true
        object.layer.cornerRadius = 12
        return object
    }()

    private let fourImage: UIImageView = {
        let object = UIImageView()
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

//    private let descriptionTextView: ReadMoreTextView = {
//        let textView = ReadMoreTextView()
//        textView.font = ThemeFont.medium(ofSize: 12)
//        textView.textColor = ThemeColor.labelColorSecondary
//        textView.backgroundColor = .clear
//        textView.isScrollEnabled = false
//        textView.maximumNumberOfLines = 5
//        textView.shouldTrim = true
//        let readMoreAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: ThemeColor.primary,
//            .font: ThemeFont.medium(ofSize: 12)
//        ]
//        let readLessAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: ThemeColor.primary,
//            .font: ThemeFont.medium(ofSize: 12)
//        ]
//
//        textView.attributedReadMoreText = NSAttributedString(string: "... Read More", attributes: readMoreAttributes)
//        textView.attributedReadLessText = NSAttributedString(string: " Read Less", attributes: readLessAttributes)
//
//        return textView
//    }()
  
  
  private let descriptionTextView: UILabel = {
      let textView = UILabel()
      textView.font = ThemeFont.medium(ofSize: 12)
      textView.textColor = ThemeColor.labelColorSecondary
      textView.backgroundColor = .clear
//      textView.isScrollEnabled = false
    textView.numberOfLines = 0
      return textView
  }()

    private var fullDescription: String = ""

    // MARK: - Initialization

    init(coordinator: DetailCoordinator, viewModel: DetailViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateBadge()
  }

    // MARK: - Setup Methods

    override func setupViews() {
        [firstImage, secondImage, thirdImage, fourImage].forEach {
            hImageStackView.addArrangedSubview($0)
        }
        [addToCartButton, buyNowButton].forEach { hButtonStackView.addArrangedSubview($0) }

        [hImageStackView, detailImage, priceLabel, productTitleLabel, descriptionTextView, hButtonStackView].forEach {
            view.addSubview($0)
        }
      setupNavigationBar()
//        configureDescriptionTextView()
        configureViews()
    }

    override func setupConstraints() {
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

    override func bindViewModel() {
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showMessage(
                    title: error.title,
                    body: error.message,
                    theme: .error
                )
            }
            .store(in: &cancellables)

        viewModel.$showSuccess
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] success in
                self?.showMessage(
                    title: success.title,
                    body: success.message,
                    theme: .success
                )
            }
            .store(in: &cancellables)
    }
  
  private func setupNavigationBar() {
    let cartButton = UIButton(type: .system)
    cartButton.setImage(UIImage(systemName: "cart.fill"), for: .normal)
    cartButton.tintColor = UIColor(hex: "F2F2F2")
    cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
    
    
    // Add badge to cart button
    var badgeAppearance = BadgeAppearance()
    badgeAppearance.backgroundColor = .red
    badgeAppearance.textColor = .white
    badgeAppearance.font = ThemeFont.bold(ofSize: 12)
    badgeAppearance.distanceFromCenterX = 13
    badgeAppearance.distanceFromCenterY = -10
    cartButton.badge(text: nil, appearance: badgeAppearance)
    
    let cartBarButton = UIBarButtonItem(customView: cartButton)
    navigationItem.rightBarButtonItems = [cartBarButton]

  }
  
  func updateCartBadge(count: Int) {
      if let cartButton = navigationItem.rightBarButtonItems?.first?.customView as? UIButton {
          if count > 0 {
              cartButton.badge(text: "\(count)")
          } else {
              cartButton.badge(text: nil)
          }
      }
  }
  
  private func updateBadge() {
      service.fetchBike()
          .receive(on: DispatchQueue.main)
          .sink { completion in
              switch completion {
              case .finished:
                  break
                  
              case .failure(let error):
                  print("Error fetching bike items: \(error.localizedDescription)")
              }
          } receiveValue: { [weak self] bike in
              self?.updateCartBadge(count: bike.count)
          }
          .store(in: &cancellables)
    
    // Add this new subscription to listen for database updates
    DatabaseService.shared.databaseUpdated
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.updateBadge()
        }
        .store(in: &cancellables)
  }

  
  @objc private func cartButtonTapped() {
    coordinator.showCartController()
  }

    // MARK: - Actions

    @objc private func addToCartButtonTapped(_ sender: UIButton) {
        viewModel.addToCart()
    }

    @objc private func buyNowButtonTapped(_ sender: UIButton) {
      let vc = PopUpViewController(product: viewModel.product)
      vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        self.present(vc, animated: true) {
            vc.view.becomeFirstResponder()
        }
    }
  
  func popUpViewController(_ controller: PopUpViewController, didSelectBuyNow bikes: [BikeDatabase]) {
    coordinator.showCheckout(bikes: bikes)
    }

    // MARK: - Private Methods

//    private func configureDescriptionTextView() {
//        descriptionTextView.text = fullDescription
//
//        // Handle size changes
//        descriptionTextView.onSizeChange = { [weak self] _ in
//            self?.view.layoutIfNeeded()
//        }
//    }

    private func configureViews() {
        productTitleLabel.text = viewModel.productName
        descriptionTextView.text = viewModel.productDescription
        priceLabel.text = viewModel.productPrice

        viewModel.productImages.forEach { imageUrl in
            [detailImage, firstImage, secondImage, thirdImage, fourImage].forEach { display in
                display.kf.setImage(with: URL(string: imageUrl))
            }
        }

        // Set Hero IDs for transitions
        detailImage.heroID = "productImage_\(viewModel.productId)"
        productTitleLabel.heroID = "productLabel_\(viewModel.productId)"
        priceLabel.heroID = "priceLabel_\(viewModel.productId)"
    }
}



