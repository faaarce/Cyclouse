//
//  HomeViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 10/09/24.
//

import Foundation
import UIKit
import Combine

struct SectionModel {
  var header: String
  var items: [Any]
  var cellType: CellType
}

class HomeViewModel {
  @Published private(set) var sections: [SectionModel] = []
  private var cancellables = Set<AnyCancellable>()
  private let service: BikeService
  
  
  init(service: BikeService) {
    self.service = service
    fetchBikes()
  }
  
  private func fetchBikes() {
    service.getBikes()
      .receive(on: DispatchQueue.main)
      .sink { completion in
        switch completion {
        case .finished:
          break
          
        case .failure(let error):
          print("Error fethcing bikes :\(error)")
        }
      } receiveValue: { [weak self] bikeDataResponse in
        self?.processBikeData(bikeDataResponse)
      }
      .store(in: &cancellables)
    
  }
  
  private func processBikeData(_ bikeData: BikeDataResponse) {
    let categories = bikeData.bikes.categories
    
    sections.removeAll()
    
    let categoryNames = categories.map { $0.categoryName }
    
    sections.append(SectionModel(header: "", items: [categoryNames], cellType: .category))
    
    for category in categories {
      sections.append(SectionModel(header: category.categoryName, items: [category.products], cellType: .cycleCard))
    }
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
    if let products = sections[indexPath.section].items.first as? [Product] {
      cell.configure(with: .cycleCard, items: products)
    }
    return cell
  }
  
  private func configureCategoryCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalViewCell", for: indexPath) as! HorizontalViewCell
    if let categories = sections[indexPath.section].items.first as? [String] {
      cell.configure(with: .category, items: categories)
    }
    return cell
  }
  
  func sizeForHeader(in section: Int, collectionViewWidth: CGFloat) -> CGSize {
    return section == 0 ? .zero : CGSize(width: collectionViewWidth, height: 40)
  }
  
  func sizeForItem(at indexPath: IndexPath, viewWidth: CGFloat) -> CGSize {
    
    
    switch sections[indexPath.section].cellType {
    case .category:
      return CGSize(width: viewWidth, height: 36)
    case .cycleCard:
      return CGSize(width: viewWidth, height: 240)
    }
  }

  
  func insetForSection(at section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }
}




//    case 0:
//      return CGSize(width: viewWidth, height: 36)
//
//    case 1:
//      return CGSize(width: viewWidth, height: 240)
//
//    case 2:
//      return CGSize(width: viewWidth, height: 36)
//
//    default:
//      return .zero
