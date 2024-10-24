import UIKit
import ReactiveCollectionsKit

class MyViewController: UIViewController {
    var collectionView: UICollectionView!
    var driver: CollectionViewDriver?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Initialize the collection view with the custom layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .white

        // Add to view hierarchy
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Initialize the driver
        driver = CollectionViewDriver(
            view: collectionView,
            viewModel: makeViewModel(),
            cellEventCoordinator: self
        )
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            // Item Size
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(100),
                heightDimension: .absolute(100)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            // Group Size
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(100),
                heightDimension: .absolute(116)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)

            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: SectionHeaderViewModel.kind,
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }

        return layout
    }

    private func makeViewModel() -> CollectionViewModel {
        // Sample data for two sections
        let section1Items = (1...10).map { Item(id: UUID(), title: "S1 Item \($0)") }
        let section2Items = (1...10).map { Item(id: UUID(), title: "S2 Item \($0)") }

        // Map items to cell view models
        let section1CellViewModels = section1Items.map {
          ExperimentCellViewModel(item: $0).eraseToAnyViewModel()
        }
        let section2CellViewModels = section2Items.map {
          ExperimentCellViewModel(item: $0).eraseToAnyViewModel()
        }

        // Create section headers
        let section1Header = SectionHeaderViewModel(id: "header1", title: "Section 1")
        let section2Header = SectionHeaderViewModel(id: "header2", title: "Section 2")

        // Create sections
        let section1 = SectionViewModel(
            id: "section1",
            cells: section1CellViewModels,
            header: section1Header.eraseToAnyViewModel()
        )
        let section2 = SectionViewModel(
            id: "section2",
            cells: section2CellViewModels,
            header: section2Header.eraseToAnyViewModel()
        )

        // Create the collection view model
        let collectionViewModel = CollectionViewModel(
            id: "main_collection",
            sections: [section1, section2]
        )

        return collectionViewModel
    }
}

// MARK: - CellEventCoordinator

extension MyViewController: CellEventCoordinator {
    func didSelectCell(viewModel: AnyCellViewModel) {
        print("Selected cell with id: \(viewModel.id)")
        // Handle cell selection
    }
}

struct SectionHeaderViewModel: SupplementaryHeaderViewModel {
    typealias ViewType = UICollectionReusableView
    let id: UniqueIdentifier
    let title: String

    func configure(view: UICollectionReusableView) {
        view.subviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}



// MARK: - SupplementaryViewModel Conformance

extension SectionHeaderViewModel {
    static let kind = UICollectionView.elementKindSectionHeader

    var registration: ViewRegistration {
        return ViewRegistration(
            reuseIdentifier: "SectionHeader",
            viewType: .supplementary(kind: Self.kind),
            method: .viewClass(ReusableSectionHeaderView.self)
        )
    }
}

// Custom reusable view for the header
class ReusableSectionHeaderView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Additional setup if needed
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Item: Hashable {
    let id: UUID
    let title: String
}
