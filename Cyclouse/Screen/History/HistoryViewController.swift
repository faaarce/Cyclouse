//
//  HistoryViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 16/09/24.
//

import UIKit

class HistoryViewController: UIViewController {

  var coordinator: HistoryCoordinator
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
//    tableView.dataSource = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    
    return tableView
  }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      configureAppearance()
      setupViews()
    }
    
  init(coordinator: HistoryCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureAppearance(){
    title = "History"
    view.backgroundColor = ThemeColor.background
  }
  
  private func setupViews(){
    view.addSubview(tableView)
  }
  
  
  
}

//extension HistoryViewController: UITableViewDataSource {
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    
//  }
//  
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    <#code#>
//  }
//}
