//
//  BikeProductCellViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 26/10/24.
//

import ReactiveCollectionsKit

struct BikeProductCellViewModel: CellViewModel {
    typealias CellType = BikeProductViewCell
    let id: UniqueIdentifier
    let product: Product
    let categoryName: String

  init(product: Product, categoryName: String) {
        self.id = "\(product.id)-\(categoryName)"
        self.product = product
    self.categoryName = categoryName
    }

    var shouldSelect: Bool { true }

    var registration: ViewRegistration {
        ViewRegistration(
            reuseIdentifier: "BikeProductViewCell",
            viewType: .cell,
            method: .viewClass(BikeProductViewCell.self)
        )
    }

    func configure(cell: BikeProductViewCell) {
        cell.configure(with: product)
    }
}
