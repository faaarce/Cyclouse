//
//  CategoryCellViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 26/10/24.
//

import ReactiveCollectionsKit

struct CategoryCellViewModel: CellViewModel {
  typealias CellType = CategoryViewCell
  let id: UniqueIdentifier
  let category: String
  
  init(category: String) {
    self.id = category
    self.category = category
  }
  
  var shouldSelect: Bool { true }
  
  var registration: ViewRegistration {
    ViewRegistration(
      reuseIdentifier: "CategoryViewCell",
      viewType: .cell,
      method: .viewClass(CategoryViewCell.self)
    )
  }
  
  func configure(cell: CategoryViewCell) {
    cell.configure(with: category)
  }
}
