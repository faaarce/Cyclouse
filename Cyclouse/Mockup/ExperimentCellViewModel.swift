//
//  ExperimentCellViewModel.swift
//  CollectionViewTesting
//
//  Created by yoga arie on 24/10/24.
//

import Foundation

import UIKit
import ReactiveCollectionsKit

struct ExperimentCellViewModel: CellViewModel {
    typealias CellType = UICollectionViewCell
    let id: UniqueIdentifier
    let title: String

    init(item: Item) {
        self.id = item.id
        self.title = item.title
    }

    func configure(cell: UICollectionViewCell) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.backgroundColor = .systemTeal

        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])

        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
    }
}
