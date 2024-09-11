//
//  CartViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 12/09/24.
//
import SnapKit
import UIKit

class CartViewController: UIViewController {
  
  var coordinator: CartCoordinator
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.dataSource = self
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    return tableView
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
    setupViews()
    layout()
  }
  
  private func configureAppearance() {
    title = "Cart"
    view.backgroundColor = ThemeColor.background
  }
  
  private func setupViews() {
    self.view.addSubview(tableView)
  }
  
  private func layout() {
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
}

extension CartViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    <#code#>
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    <#code#>
  }
}

