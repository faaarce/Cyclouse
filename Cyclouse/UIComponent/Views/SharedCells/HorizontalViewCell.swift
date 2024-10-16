//
//  HorizontalViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 08/09/24.
//
import SnapKit
import UIKit
import Combine
import CombineCocoa
import SkeletonView

enum CellType {
  case cycleCard
  case category
}

class HorizontalViewCell: UICollectionViewCell {
  private let cellSelectedSubject = PassthroughSubject<(IndexPath, Any), Never>()
  private var cellType: CellType = .cycleCard
  private var items: [Any] = []
  
  var isLoading = true {
    didSet {
      collectionView.reloadData()
    }
  }
  
  var cellSelected: AnyPublisher<(IndexPath, Any), Never> {
    return cellSelectedSubject.eraseToAnyPublisher()
  }
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collection.showsHorizontalScrollIndicator = false
    collection.backgroundColor = .clear
    return collection
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    registerCells()
    setupViews()
    layout()
    simulateLoading()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
    layout()
    simulateLoading()
  }
  
  private func simulateLoading() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      self?.isLoading = false
    }
  }
  
  private func registerCells(){
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.register(BikeProductViewCell.self, forCellWithReuseIdentifier: "BikeProductViewCell")
    self.collectionView.register(CategoryViewCell.self, forCellWithReuseIdentifier: "CategoryViewCell")
  }
  
  func configure(with type: CellType, items: [Any]) {
    self.cellType = type
    self.items = items
    self.collectionView.reloadData()
  }
  
  private func setupViews() {
    contentView.addSubview(collectionView)
  }
  
  private func layout() {
    collectionView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  
}

extension HorizontalViewCell: SkeletonCollectionViewDataSource {
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
    switch cellType {
    case .cycleCard:
              return "BikeProductViewCell"
    case .category:
              return "CategoryViewCell"
          }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch cellType {
    case .cycleCard:
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BikeProductViewCell", for: indexPath) as! BikeProductViewCell
      if isLoading {
        cell.showAnimatedGradientSkeleton()
     
      } else {
        cell.hideSkeleton()
        if let product = items[indexPath.item] as? Product {
          cell.configure(with: product)
        }
      }

      return cell
      
    case .category:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryViewCell", for: indexPath) as? CategoryViewCell else { return UICollectionViewCell() }
      
      if isLoading {
        cell.showAnimatedGradientSkeleton()
      } else {
        cell.hideSkeleton()
        if let category = items[indexPath.item] as? String {
        cell.configure(with: category)
      }
      }
    
      return cell
    }
  }
}

extension HorizontalViewCell: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch cellType {
    case .cycleCard:
      CGSize(width: 150, height: 220)
      
    case .category:
      CGSize(width: 87, height: 35)
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
  }
}

extension HorizontalViewCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.item < items.count {
      cellSelectedSubject.send((indexPath, items[indexPath.item]))
    }
  }
}
