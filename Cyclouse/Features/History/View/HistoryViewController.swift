//
//  HistoryViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 16/09/24.
//

import UIKit
import Combine
import SnapKit

class HistoryViewController: BaseViewController {
    // MARK: - Properties
    
    private var coordinator: HistoryCoordinator
    private var viewModel = HistoryViewModel()

    
    // Initialize the table view
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    // MARK: - Initialization
    
    init(coordinator: HistoryCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.isLoading = true // Start with loading state
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setupViews()
        setupConstraints()
        bindViewModel()
        viewModel.fetchHistory()
    }
    
    // MARK: - Setup Methods
    
    private func configureAppearance() {
        title = "History"
        view.backgroundColor = ThemeColor.background
    }
    
    override func setupViews() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    // MARK: - ViewModel Binding
    
    override func bindViewModel() {
        // Observe isLoading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        // Observe history data
        viewModel.$history
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // Observe errors
        viewModel.$error
            .compactMap { $0 } // Filter out nil values
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Loading State
    
    override func updateLoadingState() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Show placeholder cells when loading
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 5 : viewModel.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        if isLoading {
            cell.showLoadingPlaceholder()
        } else {
            let historyItem = viewModel.history[indexPath.row]
            cell.configure(with: historyItem)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          if !isLoading {
              let orderData = viewModel.history[indexPath.row]
              coordinator.showOrderDetail(orderData: orderData)
          }
      }
}
