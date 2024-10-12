//
//  CartViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//
import SnapKit
import UIKit
import Combine

protocol OrderBadgesUpdateDelegate {
  func updateBadge(badgeNumber: Int)
}

class CartViewController: UIViewController {
  
  @Published var bikes: GetCartResponse?
  var coordinator: CartCoordinator
  private let service = CartService()
  var delegate: OrderBadgesUpdateDelegate?
  let databaseService = DatabaseService.shared
  private var cancellables = Set<AnyCancellable>()
  var selectedStates: [String: Bool] = [:]
  private var isAllSelected = true
  
  var bikeData: [BikeV2] = [] {
    didSet {
      delegate?.updateBadge(badgeNumber: bikeData.count)
      updateViewVisibility()
    }
  }
  
  private lazy var emptyStateView: EmptyStateView = {
    let view = EmptyStateView()
    view.delegate = self // Conform to EmptyStateViewDelegate if needed
    return view
  }()
  
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
    object.addTarget(self, action: #selector(totalCheckButtonTapped), for: .touchUpInside)
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
  
  @objc private func totalCheckButtonTapped() {
      isAllSelected.toggle()
      let imageName = isAllSelected ? "checkmark.square.fill" : "square"
      checkButton.setImage(UIImage(systemName: imageName), for: .normal)

      // Update the selection state of all items
      for bike in bikeData {
          selectedStates[bike.id] = isAllSelected
      }
      tableView.reloadData()
      updateTotalPrice()
  }
  
  private func updateViewVisibility() {
    if bikeData.isEmpty {
      if !view.subviews.contains(emptyStateView) {
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
        emptyStateView.configure(
          image: UIImage(named: "bikes"),
          description: "Your cart is empty.",
          buttonTitle: "Start Shopping"
        )
      }
      emptyStateView.isHidden = false
      tableView.isHidden = true
      totalPriceView.isHidden = true
      checkoutButton.isHidden = true
    } else {
      emptyStateView.isHidden = true
      tableView.isHidden = false
      totalPriceView.isHidden = false
      checkoutButton.isHidden = false
    }
  }
  
  func updateBikeQuantity(_ bike: BikeV2, newQuantity: Int) {
    databaseService.updateBikeQuantity(bike, newQuantity: newQuantity)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          print("Error updating bike quantity: \(error)")
        }
      } receiveValue: { [weak self] _ in
        self?.fetchBikes()
      }
      .store(in: &cancellables)
  }
  
  private func fetchBikes() {
    
    databaseService.fetchBike()
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          print("Error fetching foods: \(error)")
        }
      } receiveValue: { [weak self] bike in
        self?.selectedStates = Dictionary(uniqueKeysWithValues: bike.map { ($0.id, true) })
        self?.isAllSelected = true
        self?.checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        self?.bikeData = bike
        self?.tableView.reloadData()
        self?.updateViewVisibility()
        self?.updateTotalPrice()
      }
      .store(in: &cancellables)
    
    // 2. Fetch from Add to cart API
    /*
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
     */
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
    registerCells()
  }
  
  private func layout() {
    tableView.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-25)
      $0.left.equalToSuperview().offset(20)
      $0.top.equalToSuperview()
      $0.bottom.equalTo(checkoutButton.snp.top)
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
    //    let test = bikes?.data.items.count ?? 0
    //    print(test)
    //    return test
    
    return bikeData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartViewCell", for: indexPath) as? CartViewCell else { return UITableViewCell()}
    cell.delegate = self
    let bike = bikeData[indexPath.row]
    let isChecked = selectedStates[bike.id] ?? false
    cell.indexPath = indexPath
    cell.configure(with: bike, isChecked: isChecked)
    cell.selectionStyle = .none
    cell.backgroundColor = .clear
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


extension CartViewController: CartCellDelegate {
  func minusButton(_ cell: CartViewCell) {
    guard let indexPath = tableView.indexPath(for: cell),
          indexPath.row < bikeData.count else { return }
    
    let bike = bikeData[indexPath.row]
    let newQuantity = max(1, bike.cartQuantity - 1)
    updateBikeQuantity(bike, newQuantity: newQuantity)
  }
  
  func plusButton(_ cell: CartViewCell) {
    guard let indexPath = tableView.indexPath(for: cell),
          indexPath.row < bikeData.count else { return }
    
    let bike = bikeData[indexPath.row]
    let newQuantity = min(bike.stockQuantity, bike.cartQuantity + 1)
    updateBikeQuantity(bike, newQuantity: newQuantity)
  }
  
  func checkProduct(_ cell: CartViewCell, isChecked: Bool) {
    guard let indexPath = tableView.indexPath(for: cell),
                 indexPath.row < bikeData.count else { return }
           let bike = bikeData[indexPath.row]
           selectedStates[bike.id] = isChecked

           // Update the 'Select All' button state
           if selectedStates.values.contains(false) {
               isAllSelected = false
               checkButton.setImage(UIImage(systemName: "square"), for: .normal)
           } else {
               isAllSelected = true
               checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
           }

           updateTotalPrice()
  }
  
  private func updateTotalPrice() {
      var total: Double = 0.0
      for bike in bikeData {
          if selectedStates[bike.id] ?? false {
              total += Double(bike.price) * Double(bike.cartQuantity)
          }
      }
      priceLabel.text = total.toRupiah()
  }

  
  
  func deleteButton(_ cell: CartViewCell, indexPath: IndexPath) {
    let bikeToDelete = self.bikeData[indexPath.row]
    self.databaseService.delete(bikeToDelete)
      .receive(on: DispatchQueue.main)
      .sink { result in
        switch result {
        case .finished:
          self.fetchBikes()
          
        case .failure(let error):
          print("Error deleting bike: \(error)")
        }
      } receiveValue: { _ in
        
      }
      .store(in: &cancellables)
  }
}


extension CartViewController: EmptyStateViewDelegate {
  func tapButton() {
    print("Test")
  }
  
  
}
