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
    tableView.delegate = self
    tableView.showsVerticalScrollIndicator = false
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
  
  private func registerCells() {
    tableView.register(CartViewCell.self, forCellReuseIdentifier: "CartViewCell")
  }
  
  private func configureAppearance() {
    title = "Git"
    view.backgroundColor = ThemeColor.background
  }
  
  private func setupViews() {
    self.view.addSubview(tableView)
    registerCells()
  }
  
  private func layout() {
    tableView.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-25)
      $0.left.equalToSuperview().offset(20)
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
}


extension CartViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartViewCell", for: indexPath) as? CartViewCell else { return UITableViewCell()}
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
