//
//  FilterViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 18/11/24.
//

import UIKit
import SnapKit
import ReactiveCollectionsKit


// MARK: - Filter Singleton
class FilterManager {
    static let shared = FilterManager()
    
    var selectedCategories: Set<String> = []
    var selectedBrands: Set<String> = []
    var priceRange: (min: Int, max: Int) = (0, 30_000_000)  // Price in IDR
    var sortBy: SortOption = .nameAsc
    
    private init() {}
    
    func reset() {
        selectedCategories.removeAll()
        selectedBrands.removeAll()
        priceRange = (0, 30_000_000)
        sortBy = .nameAsc
    }
}

// MARK: - Models
enum FilterSection: Int, CaseIterable {
    case categories
    case brands
    case priceRange
    case sortBy
}

enum SortOption: String, CaseIterable {
    case nameAsc = "Name (A-Z)"
    case nameDesc = "Name (Z-A)"
    case priceLowToHigh = "Price (Low to High)"
    case priceHighToLow = "Price (High to Low)"
}

struct FilterOption: Hashable {
    let title: String
    var isSelected: Bool = false
}

// MARK: - View Controller
class FilterViewController: UIViewController, CellEventCoordinator {
    // ... existing UI components ...
    
    private var categories: [String] = []
    private var brands: Set<String> = []
    
    private var categoryOptions: [FilterOption] = []
    private var brandOptions: [FilterOption] = []
    private var sortOptions: [FilterOption] = SortOption.allCases.map {
        FilterOption(title: $0.rawValue, isSelected: FilterManager.shared.sortBy.rawValue == $0.rawValue)
    }
    
    init(categories: [Category]) {
        super.init(nibName: nil, bundle: nil)
        self.setupFilterOptions(from: categories)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  private let collectionView: UICollectionView = {
         // Replace flow layout with compositional layout
         let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
             // Item size with estimated dimensions
             let itemSize = NSCollectionLayoutSize(
                 widthDimension: .estimated(100),
                 heightDimension: .estimated(40)
             )
             let item = NSCollectionLayoutItem(layoutSize: itemSize)
             item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                 leading: .fixed(4),
                 top: .fixed(4),
                 trailing: .fixed(4),
                 bottom: .fixed(4)
             )

             // Group size
             let groupSize = NSCollectionLayoutSize(
                 widthDimension: .fractionalWidth(1.0),
                 heightDimension: .estimated(40)
             )

             // Group with flexible width to allow wrapping
             let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

             // Section with content insets and inter-group spacing
             let section = NSCollectionLayoutSection(group: group)
             section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
             section.interGroupSpacing = 8

             // Header configuration
             let headerSize = NSCollectionLayoutSize(
                 widthDimension: .fractionalWidth(1.0),
                 heightDimension: .absolute(40)
             )
             let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                 layoutSize: headerSize,
                 elementKind: UICollectionView.elementKindSectionHeader,
                 alignment: .top
             )
             section.boundarySupplementaryItems = [headerItem]

             return section
         }

         let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
         cv.backgroundColor = .clear
         return cv
     }()

     private let applyButton: UIButton = {
         let button = UIButton(type: .system)
         button.setTitle("Apply Filters", for: .normal)
         button.backgroundColor = ThemeColor.primary
         button.setTitleColor(.black, for: .normal)
         button.titleLabel?.font = ThemeFont.medium(ofSize: 16)
         button.layer.cornerRadius = 8
         return button
     }()

     private let closeButton: UIButton = {
         let button = UIButton(type: .system)
         button.setImage(UIImage(systemName: "xmark"), for: .normal)
         button.tintColor = ThemeColor.primary
         return button
     }()

     private let resetButton: UIButton = {
         let button = UIButton(type: .system)
         button.setTitle("Reset", for: .normal)
         button.tintColor = ThemeColor.primary
         return button
     }()

     private var driver: CollectionViewDriver?

     // Add these setup methods
     private func setupUI() {
         view.backgroundColor = ThemeColor.background

         view.addSubview(closeButton)
         view.addSubview(resetButton)
         view.addSubview(collectionView)
         view.addSubview(applyButton)

         closeButton.snp.makeConstraints { make in
             make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
         }

         resetButton.snp.makeConstraints { make in
             make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
         }

         collectionView.snp.makeConstraints { make in
             make.top.equalTo(closeButton.snp.bottom).offset(16)
             make.leading.trailing.equalToSuperview()
             make.bottom.equalTo(applyButton.snp.top).offset(-16)
         }

         applyButton.snp.makeConstraints { make in
             make.leading.trailing.equalToSuperview().inset(16)
             make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
             make.height.equalTo(50)
         }
     }

     private func setupCollectionView() {
         driver = CollectionViewDriver(
             view: collectionView,
             viewModel: makeViewModel(),
             cellEventCoordinator: self
         )
     }

     private func setupActions() {
         closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
         resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
         applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
     }

     @objc private func closeButtonTapped() {
         dismiss(animated: true)
     }

     private func updateCollectionView() {
         let viewModel = makeViewModel()
         driver?.update(viewModel: viewModel, animated: true)
     }
  
    private func setupFilterOptions(from categories: [Category]) {
        // Extract unique categories
        self.categories = categories.map { $0.categoryName }
        self.categoryOptions = self.categories.map { category in
            FilterOption(
                title: category,
                isSelected: FilterManager.shared.selectedCategories.contains(category)
            )
        }
        
        // Extract unique brands
        self.brands = Set(categories.flatMap { category in
            category.products.map { $0.brand }
        })
        self.brandOptions = Array(brands).map { brand in
            FilterOption(
                title: brand,
                isSelected: FilterManager.shared.selectedBrands.contains(brand)
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() //ERROR:- Cannot find 'setupUI, setupCollectionView, setupActions, updateCollectionView' in scope
        setupCollectionView()
        setupActions()
        updateCollectionView()
    }
    
    @objc private func resetButtonTapped() {
        FilterManager.shared.reset()
        
        // Reset all options
        categoryOptions = categoryOptions.map {
            FilterOption(title: $0.title, isSelected: false)
        }
        brandOptions = brandOptions.map {
            FilterOption(title: $0.title, isSelected: false)
        }
        sortOptions = SortOption.allCases.map {
            FilterOption(title: $0.rawValue, isSelected: $0 == .nameAsc)
        }
        
        updateCollectionView() // ERROR:- Cannot find 'updateCollectionView' in scope
    }
    
    @objc private func applyButtonTapped() {
        // Save current selections to FilterManager
        FilterManager.shared.selectedCategories = Set(
            categoryOptions.filter { $0.isSelected }.map { $0.title }
        )
        FilterManager.shared.selectedBrands = Set(
            brandOptions.filter { $0.isSelected }.map { $0.title }
        )
        
        if let selectedSortOption = sortOptions.first(where: { $0.isSelected }),
           let sortBy = SortOption.allCases.first(where: { $0.rawValue == selectedSortOption.title }) {
            FilterManager.shared.sortBy = sortBy
        }
      NotificationCenter.default.post(name: NSNotification.Name("FilterSettingsChanged"), object: nil)

        dismiss(animated: true)
    }
    
    private func makeViewModel() -> CollectionViewModel {
        var sections: [SectionViewModel] = []
        
        // Categories Section
        let categoryCells = categoryOptions.map { option in
            FilterOptionCellViewModel(
                option: option,
                sectionType: .categories
            ).eraseToAnyViewModel()
        }
        sections.append(SectionViewModel(
            id: "categoriesSection",
            cells: categoryCells,
            header: FilterHeaderViewModel(title: "Categories").eraseToAnyViewModel()
        ))
        
        // Brands Section
        let brandCells = brandOptions.map { option in
            FilterOptionCellViewModel(
                option: option,
                sectionType: .brands
            ).eraseToAnyViewModel()
        }
        sections.append(SectionViewModel(
            id: "brandsSection",
            cells: brandCells,
            header: FilterHeaderViewModel(title: "Brands").eraseToAnyViewModel()
        ))
        
        // Sort Options Section
        let sortCells = sortOptions.map { option in
            FilterOptionCellViewModel(
                option: option,
                sectionType: .sortBy
            ).eraseToAnyViewModel()
        }
        sections.append(SectionViewModel(
            id: "sortSection",
            cells: sortCells,
            header: FilterHeaderViewModel(title: "Sort By").eraseToAnyViewModel()
        ))
        
        return CollectionViewModel(id: "filterCollectionView", sections: sections)
    }
    
    // MARK: - CellEventCoordinator
    func didSelectCell(viewModel: any CellViewModel) {
        if let filterOptionVM = viewModel as? FilterOptionCellViewModel {
            switch filterOptionVM.sectionType {
            case .categories:
                if let index = categoryOptions.firstIndex(where: { $0.title == filterOptionVM.option.title }) {
                    categoryOptions[index].isSelected.toggle()
                }
            case .brands:
                if let index = brandOptions.firstIndex(where: { $0.title == filterOptionVM.option.title }) {
                    brandOptions[index].isSelected.toggle()
                }
            case .sortBy:
                // For sort options, only one can be selected
                sortOptions = sortOptions.map {
                    FilterOption(title: $0.title, isSelected: $0.title == filterOptionVM.option.title)
                }
            default:
                break
            }
            updateCollectionView() // ERROR: Cannot find 'updateCollectionView' in scope
        }
    }
}

struct FilterOptionCellViewModel: CellViewModel {
    typealias CellType = CapsuleCell

    let id: UniqueIdentifier
    let option: FilterOption
    let sectionType: FilterSection

    init(option: FilterOption, sectionType: FilterSection) {
        self.id = "\(sectionType.rawValue)-\(option.title)"
        self.option = option
        self.sectionType = sectionType
    }

    var registration: ViewRegistration {
        ViewRegistration(
            reuseIdentifier: "FilterOptionCell",
            viewType: .cell,
            method: .viewClass(CapsuleCell.self)
        )
    }

    func configure(cell: CapsuleCell) {
        cell.configure(with: option.title, isSelected: option.isSelected)
    }
}

class FilterHeaderView: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(ofSize: 16)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    private func setupViews() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct FilterHeaderViewModel: SupplementaryViewModel {
    typealias ViewType = FilterHeaderView

    let id: UniqueIdentifier
    let title: String

    init(title: String) {
        self.id = "header-\(title)"
        self.title = title
    }

    var kind: String {
        UICollectionView.elementKindSectionHeader
    }

    var registration: ViewRegistration {
        ViewRegistration(
            reuseIdentifier: "FilterHeaderView",
            viewType: .supplementary(kind: kind),
            method: .viewClass(FilterHeaderView.self)
        )
    }

    func configure(view: FilterHeaderView) {
        view.titleLabel.text = title
    }
}

class CapsuleCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = ThemeFont.medium(ofSize: 14)
        return label
    }()

    private let checkmark: UIImageView = {
        let image = UIImage(systemName: "checkmark.circle.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.isHidden = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(checkmark)
        contentView.addSubview(label)

        checkmark.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(checkmark.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(4)
        }

        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }

    func configure(with text: String, isSelected: Bool) {
        label.text = text

        if isSelected {
            contentView.backgroundColor = ThemeColor.primary
            label.textColor = .black
            checkmark.isHidden = false
        } else {
            contentView.backgroundColor = ThemeColor.cardFillColor
            label.textColor = .white
            checkmark.isHidden = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
