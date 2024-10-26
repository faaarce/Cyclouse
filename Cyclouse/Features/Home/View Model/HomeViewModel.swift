//
//  HomeViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 10/09/24.
//
/*
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
  private var allSections: [SectionModel] = []
  
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
        self?.processBikeData(bikeDataResponse.value)
      }
      .store(in: &cancellables)
    
  }
  
  private func processBikeData(_ bikeData: BikeDataResponse) {
     let categories = bikeData.bikes.categories

     allSections.removeAll()
     sections.removeAll()

     let categoryNames = categories.map { $0.categoryName }

     allSections.append(SectionModel(header: "", items: [categoryNames], cellType: .category))
     sections.append(SectionModel(header: "", items: [categoryNames], cellType: .category))

     for category in categories {
       let sectionModel = SectionModel(header: category.categoryName, items: [category.products], cellType: .cycleCard)
       allSections.append(sectionModel)
       sections.append(sectionModel)
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
      print("DEBUG: Configuring BikeProductCell with \(products.count) products")
      cell.configure(with: .cycleCard, items: products)
    }
    return cell
  }
  
  private func configureCategoryCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalViewCell", for: indexPath) as! HorizontalViewCell
    if let categories = sections[indexPath.section].items.first as? [String] {
      print("DEBUG: Configuring CategoryCell with \(categories.count) categories")
      cell.configure(with: .category, items: categories)
    }
    return cell
  }
  
  func filterProducts(by category: String) {
      if category.isEmpty {
        sections = allSections // Reset to show all sections
      } else {
        sections = allSections.filter { $0.cellType == .category || $0.header == category }
      }
      // Note: We don't need to call collectionView.reloadData() here because the @Published property will trigger the binding in HomeViewController
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

*/


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
