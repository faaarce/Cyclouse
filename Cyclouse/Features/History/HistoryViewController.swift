//
//  HistoryViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 16/09/24.
//
import SnapKit
import UIKit
import SkeletonView

class HistoryViewController: UIViewController {
  
  var coordinator: HistoryCoordinator
  var isLoading = true
  
  let dummyItems = [
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    Dummy(name: "Mountain Bike", price: 1000000, qty: 1, image: "bike"),
    
  ]
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.isSkeletonable = true
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureAppearance()
    setupViews()
    layout()
    
    showCustomSkeletonAnimation()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.isLoading = false
      self.hideSkeletonWithAnimation()
    }
  }
  
  init(coordinator: HistoryCoordinator) {
    self.coordinator = coordinator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func showCustomSkeletonAnimation() {
         isLoading = true
         view.showAnimatedSkeleton { (layer) -> CAAnimation in
             let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
             pulseAnimation.fromValue = 0.5
             pulseAnimation.toValue = 1
             pulseAnimation.duration = 1.0
             pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
             pulseAnimation.autoreverses = true
             pulseAnimation.repeatCount = .infinity
             
             let colorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
             colorAnimation.fromValue = UIColor.systemGray5.cgColor
             colorAnimation.toValue = UIColor.systemGray3.cgColor
             colorAnimation.duration = 1.5
             colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
             colorAnimation.autoreverses = true
             colorAnimation.repeatCount = .infinity
             
             let animationGroup = CAAnimationGroup()
             animationGroup.animations = [pulseAnimation, colorAnimation]
             animationGroup.duration = 1.5
             animationGroup.repeatCount = .infinity
             
             return animationGroup
         }
     }
     
  
  private func registerCells(){
    tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryTableViewCell")
  }
  
  private func showSkeletonWithAnimation() {
       let gradient = SkeletonGradient(baseColor: .clouds)
       let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
       view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
   }
   
   private func hideSkeletonWithAnimation() {
       view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
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

extension HistoryViewController: UITableViewDataSource, SkeletonTableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dummyItems.count
  }
  
  func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "HistoryTableViewCell"
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isLoading ? dummyItems.count : dummyItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
    cell.selectionStyle = .none
    cell.backgroundColor = .clear
    if !isLoading {
      let item = dummyItems[indexPath.row]
      cell.configure(with: item)
    } else {
      cell.showCustomSkeletonAnimation()
    }
    return cell
  }
  
  
}

extension HistoryViewController: UITableViewDelegate {
  
}
