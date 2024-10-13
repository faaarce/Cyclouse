//
//  HistoryViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 16/09/24.
//
import SnapKit
import UIKit

class HistoryViewController: UIViewController {

  var coordinator: HistoryCoordinator
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    
    return tableView
  }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      configureAppearance()
      setupViews()
      layout()
    }
    
  init(coordinator: HistoryCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func registerCells(){
    tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryTableViewCell")
  }
  
  private func configureAppearance(){
    title = "History"
    view.backgroundColor = ThemeColor.background
  }
  
  private func setupViews(){
    view.addSubview(tableView)
    registerCells()
  }
  
  private func layout() {
    tableView.snp.makeConstraints {
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
}

extension HistoryViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
    cell.selectionStyle = .none
    cell.backgroundColor = .clear
    return cell
  }
  
  
}

extension HistoryViewController: UITableViewDelegate {

}
