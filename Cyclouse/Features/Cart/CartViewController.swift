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


import UIKit
import Combine
import CombineCocoa

class CartViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: CartViewModel
    private var cancellables = Set<AnyCancellable>()
    var coordinator: CartCoordinator

    // MARK: - UI Elements
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.delegate = self
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CartViewCell.self, forCellReuseIdentifier: "CartViewCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()

    private let checkoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Checkout", for: .normal)
        button.setTitleColor(ThemeColor.black, for: .normal)
        button.backgroundColor = ThemeColor.primary
        return button
    }()

    private let totalPriceView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = ThemeColor.cardFillColor
        return view
    }()

    private let checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = ThemeColor.labelColorSecondary
        button.contentMode = .scaleAspectFit
        return button
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

    // MARK: - Initializer
    init(coordinator: CartCoordinator, viewModel: CartViewModel = CartViewModel()) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setupViews()
        layout()
        bindViewModel()
        bindUIActions()
    }

    // MARK: - Binding Methods
    private func bindViewModel() {
        // Update tableView when bikeData changes
        viewModel.$bikeData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bikes in
                self?.tableView.reloadData()
                self?.updateViewVisibility()
            }
            .store(in: &cancellables)

        // Update total price label
        viewModel.$totalPrice
            .map { $0.toRupiah() }
            .assign(to: \.text, on: priceLabel)
            .store(in: &cancellables)

        // Update select all button image
        viewModel.$isAllSelected
            .map { $0 ? "checkmark.square.fill" : "square" }
            .sink { [weak self] imageName in
                   self?.checkButton.setImage(UIImage(systemName: imageName), for: .normal)
               }
            .store(in: &cancellables)
    }

    private func bindUIActions() {
        // Select All button tap
        checkButton.tapPublisher
            .sink { [weak self] in
                self?.viewModel.toggleSelectAll()
            }
            .store(in: &cancellables)

        // Checkout button tap
        checkoutButton.tapPublisher
            .sink { [weak self] in
                self?.checkoutButtonTapped()
            }
            .store(in: &cancellables)
    }

    // MARK: - UI Setup
    private func configureAppearance() {
        title = "Cart"
        view.backgroundColor = ThemeColor.background
    }

    private func setupViews() {
        totalPriceView.addSubview(checkButton)
        totalPriceView.addSubview(totalChecklistLabel)
        totalPriceView.addSubview(priceLabel)
        totalPriceView.addSubview(totalLabel)
        view.addSubview(totalPriceView)
        view.addSubview(tableView)
        view.addSubview(checkoutButton)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func layout() {
        tableView.snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.right.equalToSuperview().offset(-25)
            $0.bottom.equalTo(checkoutButton.snp.top)
        }

        checkoutButton.snp.makeConstraints {
            $0.bottom.right.equalToSuperview()
            $0.width.equalTo(113)
            $0.height.equalTo(75)
        }

        totalPriceView.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.right.equalTo(checkoutButton.snp.left)
            $0.height.equalTo(75)
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

    private func updateViewVisibility() {
        let isEmpty = viewModel.bikeData.isEmpty
        if isEmpty {
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
    private func checkoutButtonTapped() {
        let selectedBikes = viewModel.getSelectedBikes()
        if !selectedBikes.isEmpty {
            coordinator.showCheckout(bikes: selectedBikes)
        } else {
            // Show alert that no items are selected
            let alert = UIAlertController(
                title: "No Items Selected",
                message: "Please select at least one item to checkout",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
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
        cell.delegate = self
        let bike = viewModel.bikeData[indexPath.row]
        let isChecked = viewModel.selectedStates[bike.id] ?? false
        cell.indexPath = indexPath
        cell.configure(with: bike, isChecked: isChecked)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate {
   
}

// MARK: - CartCellDelegate
extension CartViewController: CartCellDelegate {
    func minusButton(_ cell: CartViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              indexPath.row < viewModel.bikeData.count else { return }

        let bike = viewModel.bikeData[indexPath.row]
        let newQuantity = max(1, bike.cartQuantity - 1)
        viewModel.updateBikeQuantity(bike, newQuantity: newQuantity)
    }

    func plusButton(_ cell: CartViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              indexPath.row < viewModel.bikeData.count else { return }

        let bike = viewModel.bikeData[indexPath.row]
        let newQuantity = min(bike.stockQuantity, bike.cartQuantity + 1)
        viewModel.updateBikeQuantity(bike, newQuantity: newQuantity)
    }

    func checkProduct(_ cell: CartViewCell, isChecked: Bool) {
        guard let indexPath = tableView.indexPath(for: cell),
              indexPath.row < viewModel.bikeData.count else { return }
        let bike = viewModel.bikeData[indexPath.row]
        viewModel.selectedStates[bike.id] = isChecked

        // Update the 'Select All' button state
        viewModel.isAllSelected = !viewModel.selectedStates.values.contains(false)
    }

    func deleteButton(_ cell: CartViewCell, indexPath: IndexPath) {
        viewModel.deleteBike(at: indexPath)
    }
}

// MARK: - EmptyStateViewDelegate
extension CartViewController: EmptyStateViewDelegate {
    func tapButton() {
        print("Start Shopping tapped")
        // Implement navigation to shopping screen if necessary
    }
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
