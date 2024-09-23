//
//  LoadingsViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 22/09/24.
//
import SnapKit
import UIKit

class LoadingsViewController: UIViewController {

  private let loadingView: UIActivityIndicatorView = {
    let object = UIActivityIndicatorView(frame: .zero)
    return object
  }()
  
  private let messageLabel: UILabel = {
    LabelFactory.build(text: "Loading...", font: ThemeFont.medium(ofSize: 16))
  }()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
