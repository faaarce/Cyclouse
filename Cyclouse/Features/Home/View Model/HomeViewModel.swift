//
//  HomeViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 10/09/24.
//

import Foundation
import UIKit


struct SectionModel {
  var header: String
  var items: [Bike]
  var cellType: CellType
}

class HomeViewModel {
  @Published private(set) var sections: [SectionModel] = []
  var bikeData: [Bike] = []
  init(bikeData: [Bike]) {
    self.bikeData = bikeData
    guard bikeData.count >= 3 else {
      fatalError("Not enough food items to populate all sections")
    }
    
    let placeholderItem = Bike(name: "", type: "", price: 0.0, numberSold: 0)
    
    self.sections = [
      SectionModel(header: "Category", items: [placeholderItem], cellType: .category),
      SectionModel(header: "All Bike Product" , items: [placeholderItem], cellType: .cycleCard),
      SectionModel(header: "Wheelset", items: [placeholderItem], cellType: .category)
    ]
  }
  
  func configureCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let section = sections[indexPath.section]
    
    switch section.cellType {
    case .category:
      return configureCategoryCell(collectionView: collectionView, indexPath: indexPath)
    case .cycleCard:
      return configureBikeProductCell(collectionView: collectionView, indexPath: indexPath)
    }
  }
  
  private func configureBikeProductCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalViewCell", for: indexPath) as! HorizontalViewCell
    cell.configure(with: .cycleCard, bikes: bikeData)
    return cell
  }
  
  private func configureCategoryCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalViewCell", for: indexPath) as! HorizontalViewCell
    cell.configure(with: .category, bikes: bikeData)
    return cell
  }
  
  func sizeForHeader(in section: Int, collectionViewWidth: CGFloat) -> CGSize {
    return CGSize(width: collectionViewWidth, height: 40)
  }
  
  func sizeForItem(at indexPath: IndexPath, viewWidth: CGFloat) -> CGSize {
    switch indexPath.section {
      
    case 0:
      return CGSize(width: viewWidth, height: 36)
      
    case 1:
      return CGSize(width: viewWidth, height: 240)
      
    case 2:
      return CGSize(width: viewWidth, height: 36)
      
    default:
      return .zero
    }
  }
  
  func insetForSection(at section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }
}
