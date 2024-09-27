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

enum CellType {
  case cycleCard
  case category
}

class HorizontalViewCell: UICollectionViewCell {
  private let cellSelectedSubject = PassthroughSubject<(IndexPath, Any), Never>()
  private var cellType: CellType = .cycleCard
  private var items: [Any] = []
  
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
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
    layout()
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

extension HorizontalViewCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch cellType {
    case .cycleCard:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BikeProductViewCell", for: indexPath) as? BikeProductViewCell else { return UICollectionViewCell() }
      if let product = items[indexPath.item] as? Product {
        cell.configure(with: product)
      }
      cell.backgroundColor = ThemeColor.cardFillColor
      cell.layer.cornerRadius = 8
      return cell
      
    case .category:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryViewCell", for: indexPath) as? CategoryViewCell else { return UICollectionViewCell() }
      if let category = items[indexPath.item] as? String {
        cell.configure(with: category)
      }
      cell.backgroundColor = ThemeColor.primary
      cell.layer.cornerRadius = 10
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
