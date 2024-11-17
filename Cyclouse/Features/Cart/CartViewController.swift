//
//  CartViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//
import SnapKit
import UIKit
import Combine
import CombineCocoa

protocol OrderBadgesUpdateDelegate {
    func updateBadge(badgeNumber: Int)
}

class CartViewController: BaseViewController {

    // MARK: - Properties

    var coordinator: CartCoordinator
    var viewModel: CartViewModel!

    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.delegate = self
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
        LabelFactory.build(text: "Select All", font: ThemeFont.medium(ofSize: 14), textColor: .white)
    }()

    private let priceLabel: UILabel = {
        LabelFactory.build(text: "Rp 0", font: ThemeFont.medium(ofSize: 14), textColor: ThemeColor.primary)
    }()

    private let totalLabel: UILabel = {
        LabelFactory.build(text: "Total", font: ThemeFont.medium(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
    }()

    // MARK: - Initialization

    init(coordinator: CartCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        // Initialize ViewModel before calling super.viewDidLoad()
        viewModel = CartViewModel()

        super.viewDidLoad()
        title = "Cart"
    }

    // MARK: - Setup Methods

    override func setupViews() {
        super.setupViews()
        totalPriceView.addSubview(checkButton)
        totalPriceView.addSubview(totalChecklistLabel)
        totalPriceView.addSubview(priceLabel)
        totalPriceView.addSubview(totalLabel)
        view.addSubview(totalPriceView)
        view.addSubview(tableView)
        view.addSubview(checkoutButton)
        registerCells()
    }

    override func setupConstraints() {
        super.setupConstraints()
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

    override func bindViewModel() {
        super.bindViewModel()

        // Subscribe to bikeData
        viewModel.$bikeData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bikes in
                self?.tableView.reloadData()
                self?.updateViewVisibility()
            }
            .store(in: &cancellables)

        // Subscribe to isAllSelected
        viewModel.$isAllSelected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAllSelected in
                let imageName = isAllSelected ? "checkmark.square.fill" : "square"
                self?.checkButton.setImage(UIImage(systemName: imageName), for: .normal)
            }
            .store(in: &cancellables)

        // Subscribe to totalPrice
        viewModel.$totalPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] total in
                self?.priceLabel.text = total.toRupiah()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func registerCells() {
        tableView.register(CartViewCell.self, forCellReuseIdentifier: "CartViewCell")
    }

    private func updateViewVisibility() {
        if viewModel.bikeData.isEmpty {
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

    // MARK: - Actions

    @objc private func totalCheckButtonTapped() {
        viewModel.toggleSelectAll()
    }

    @objc private func checkoutButtonTapped() {
        // Filter selected bikes
        let selectedBikes = viewModel.bikeData.filter { bike in
            viewModel.selectedStates[bike.id] ?? false
        }

        // Only proceed if there are selected bikes
        if !selectedBikes.isEmpty {
            coordinator.showCheckout(bikes: selectedBikes)
        } else {
            showMessage(
                title: "No Items Selected",
                body: "Please select at least one item to checkout",
                theme: .warning
            )
        }
    }
}


extension CartViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bikeData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartViewCell", for: indexPath) as? CartViewCell else {
            return UITableViewCell()
        }
      cell.selectionStyle = .none
      cell.backgroundColor = .clear
        cell.delegate = self
        let bike = viewModel.bikeData[indexPath.row]
        let isChecked = viewModel.selectedStates[bike.id] ?? false
        cell.configure(with: bike, isChecked: isChecked)
        return cell
    }
}

extension CartViewController: EmptyStateViewDelegate {
    func tapButton() {
        // Implement navigation to the shopping screen or desired action

    }
}


extension CartViewController: CartCellDelegate {
  func minusButton(_ cell: CartViewCell) {
    guard let indexPath = tableView.indexPath(for: cell),
          indexPath.row < viewModel.bikeData.count else { return }
    
    let bike = viewModel.bikeData[indexPath.row]
    let newQuantity = max(1, bike.cartQuantity - 1)
    viewModel.updateBikeQuantity(bike, newQuantity: newQuantity)
    
    // Update the cell's quantityLabel and button states
    cell.updateQuantityLabel(newQuantity)
    cell.updateButtonState(stockQuantity: bike.stockQuantity, cartQuantity: newQuantity)
  }
  
  func plusButton(_ cell: CartViewCell) {
    guard let indexPath = tableView.indexPath(for: cell),
          indexPath.row < viewModel.bikeData.count else { return }
    
    let bike = viewModel.bikeData[indexPath.row]
    let newQuantity = min(bike.stockQuantity, bike.cartQuantity + 1)
    viewModel.updateBikeQuantity(bike, newQuantity: newQuantity)
    
    // Update the cell's quantityLabel and button states
    cell.updateQuantityLabel(newQuantity)
    cell.updateButtonState(stockQuantity: bike.stockQuantity, cartQuantity: newQuantity)
  }
  func checkProduct(_ cell: CartViewCell, isChecked: Bool) {
    guard let indexPath = tableView.indexPath(for: cell),
          indexPath.row < viewModel.bikeData.count else { return }
    let bike = viewModel.bikeData[indexPath.row]
    viewModel.selectedStates[bike.id] = isChecked
    
    // Update the 'Select All' button state
    viewModel.isAllSelected = !viewModel.selectedStates.values.contains(false)
    
    viewModel.updateTotalPrice()
  }
  
  func deleteButton(_ cell: CartViewCell) {
    if let indexPath = tableView.indexPath(for: cell) {
      let bikeToDelete = viewModel.bikeData[indexPath.row]
      viewModel.deleteBike(bikeToDelete)
    }
  }
}

extension CartViewController: UITableViewDelegate {
  
}


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
