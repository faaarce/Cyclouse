//
//  BikeProductCellViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 26/10/24.
//
import UIKit
import ReactiveCollectionsKit

 struct BikeProductCellViewModel: CellViewModel {
  typealias CellType = BikeProductViewCell
  let id: UniqueIdentifier
  let product: Product?
  let categoryName: String?
  let isLoading: Bool

  // Initializer for real data
  init(product: Product, categoryName: String) {
      self.id = "\(product.id)-\(categoryName)"
      self.product = product
      self.categoryName = categoryName
      self.isLoading = false
  }

  // Initializer for placeholder data
  init(isLoading: Bool) {
      self.id = UUID().uuidString
      self.product = nil
      self.categoryName = nil
      self.isLoading = isLoading
  }

  var shouldSelect: Bool { !isLoading }

  var registration: ViewRegistration {
      ViewRegistration(
          reuseIdentifier: "BikeProductViewCell",
          viewType: .cell,
          method: .viewClass(BikeProductViewCell.self)
      )
  }

  func configure(cell: BikeProductViewCell) {
      if isLoading {
          cell.showAnimatedGradientSkeleton()
      } else {
          cell.hideSkeleton()
          if let product = product {
              cell.configure(with: product)
          }
      }
  }
}

