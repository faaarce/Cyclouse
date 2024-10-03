//
//  CartViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//
import SnapKit
import UIKit
import Combine

class CartViewController: UIViewController {
  
  @Published var bikes: GetCartResponse?
  var coordinator: CartCoordinator
  private let service = CartService()
  
//  private let service = BikeService()
  private var cancellables = Set<AnyCancellable>()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    return tableView
  }()
  
  lazy var emptyStateView = EmptyStateView(frame: tableView.frame)
  
  private let checkoutButton: UIButton = {
    let button = UIButton()
    button.setTitle("Checkout", for: .normal)
    button.setTitleColor(ThemeColor.black, for: .normal)
    button.backgroundColor = ThemeColor.primary
    button.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
    return button
  }()
  
  private let totalPriceView: UIView = {
    let object = UIView(frame: .zero)
    object.backgroundColor = ThemeColor.cardFillColor
    return object
  }()
  
  private let checkButton: UIButton = {
    let object = UIButton(type: .system)
    object.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
    object.tintColor = ThemeColor.labelColorSecondary
    object.contentMode = .scaleAspectFit
    return object
  }()
  
  private let totalChecklistLabel: UILabel = {
    LabelFactory.build(text: "Semua", font: ThemeFont.medium(ofSize: 14), textColor: .white)
  }()
  
  private let priceLabel: UILabel = {
    LabelFactory.build(text: "Rp 5,000,000", font: ThemeFont.medium(ofSize: 14), textColor: ThemeColor.primary)
  }()
  
  private let totalLabel: UILabel = {
    LabelFactory.build(text: "Total", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
  }()
  
  init(coordinator: CartCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureAppearance()
    fetchBikes()
    setupViews()
    layout()
  }
  
  private func updateEmptyStateView() {
    
    emptyStateView.configure(image: UIImage(named: "bikes"), description: "No Data Available", buttonTitle:  "Order")
    let isEmpty = bikes?.data.items.isEmpty ?? true
    tableView.isHidden = isEmpty
    totalPriceView.isHidden = isEmpty
    checkButton.isHidden = isEmpty
    shouldShowErrorView(isEmpty)
  }
  
  func shouldShowErrorView(_ status: Bool) {
      switch status {
      case true:
          if !view.subviews.contains(emptyStateView) {
              view.addSubview(emptyStateView)
          } else {
              emptyStateView.isHidden = false
          }
      case false:
          if view.subviews.contains(emptyStateView) {
              emptyStateView.isHidden = true
          }
      }
  }

  
  private func fetchBikes() {
    service.getCart()
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
        case .finished:
          print("Successfully retrieved cart")
          
        case .failure(let error):
          print("Failed to retrieve cart: \(error)")
        }
      } receiveValue: { response in
        print(response.value)
            self.bikes = response.value
        
        self.tableView.reloadData()
        self.updateEmptyStateView()
      }
      .store(in: &cancellables)

  }
  
  @objc func checkoutButtonTapped() {
    print("Check button tapped")
  }
  
  private func registerCells() {
    tableView.register(CartViewCell.self, forCellReuseIdentifier: "CartViewCell")
  }
  
  private func configureAppearance() {
    title = "Cart"
    view.backgroundColor = ThemeColor.background
  }
  
  private func setupViews() {
    totalPriceView.addSubview(checkButton)
    totalPriceView.addSubview(totalChecklistLabel)
    totalPriceView.addSubview(priceLabel)
    totalPriceView.addSubview(totalLabel)
    self.view.addSubview(totalPriceView)
    self.view.addSubview(tableView)
    self.view.addSubview(checkoutButton)
    self.view.addSubview(emptyStateView)
    registerCells()
  }
  
  private func layout() {
    tableView.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-25)
      $0.left.equalToSuperview().offset(20)
      $0.top.equalToSuperview()
      $0.bottom.equalTo(checkoutButton.snp.top)
    }
    
    emptyStateView.snp.makeConstraints { make in
      make.edges.equalTo(tableView)
    }
    
    checkoutButton.snp.makeConstraints {
      $0.bottom.equalToSuperview()
      $0.width.equalTo(113)
      $0.right.equalToSuperview()
      $0.height.equalTo(75)
    }
    
    totalPriceView.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.height.equalTo(75)
      $0.right.equalTo(checkoutButton.snp.left)
    }
    
    checkButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalToSuperview().offset(20)
    }
    
    totalChecklistLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalTo(checkButton.snp.right).offset(10)
    }

    totalLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalTo(totalChecklistLabel.snp.right).offset(20)
    }
    
    priceLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.left.equalTo(totalLabel.snp.right).offset(5)
    }
    
  }
  
}


extension CartViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
   return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let test = bikes?.data.items.count ?? 0
    print(test)
    return test
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartViewCell", for: indexPath) as? CartViewCell else { return UITableViewCell()}
    cell.selectionStyle = .none
    cell.backgroundColor = .clear
    cell.bikeNameLabel.text = bikes?.data.items[indexPath.row].productId
    return cell
  }
}


extension CartViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
      return false  // Prevent the cell from highlighting when tapped
    }
}
