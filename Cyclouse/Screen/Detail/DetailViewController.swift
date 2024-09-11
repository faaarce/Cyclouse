//
//  DetailViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 11/09/24.
//

import UIKit

class DetailViewController: UIViewController {

  var coordinator: DetailCoordinator
  
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "Detail"
      view.backgroundColor = .yellow
    }
    
  init(coordinator: DetailCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  

}
