//
//  FilterViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 18/11/24.
//

import UIKit
import SnapKit
import ReactiveCollectionsKit
// FilterViewController.swift
// Cyclouse

// Created by yoga arie on 18/11/24.

import UIKit
import SnapKit
import ReactiveCollectionsKit

// MARK: - Filter Singleton
class FilterManager {
    static let shared = FilterManager()
    
    var selectedPetTypes: Set<String> = []
    var selectedBreeds: Set<String> = []
    var ageRange: (min: Int, max: Int) = (5, 16)
    var selectedGender: String?
    var isVaccinated: Bool = false
    var isNeutered: Bool = false
    var selectedCity: String?
    var selectedDistrict: String?
    
    private init() {}
}

// MARK: - Models
enum FilterSection: Int, CaseIterable {
    case petType
    case breed
    case ageRange
    case gender
    case vaccination
    case neutered
    case location
}

struct FilterOption: Hashable {
    let title: String
    var isSelected: Bool = false
}

// MARK: - View Controller
class FilterViewController: UIViewController, CellEventCoordinator {
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
        ButtonFactory.build(title: "Apply Filters", font: ThemeFont.medium(ofSize: 12), radius: 8)
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

    // Filter options
    private var petTypeOptions: [FilterOption] = [
        FilterOption(title: "Cat"),
        FilterOption(title: "Dog", isSelected: true),
        FilterOption(title: "Hamster")
    ]

    private var breedOptions: [FilterOption] = [
        FilterOption(title: "Golden Retriever", isSelected: true),
        FilterOption(title: "Labrador"),
        FilterOption(title: "ABGHAEHGJE"),
        FilterOption(title: "LabrWBTW4ador"),
        FilterOption(title: "LabBTW4Brador"),
        FilterOption(title: "Lab4WBTrador"),
        FilterOption(title: "LabrW4BTWador"),
        FilterOption(title: "LabWBTWBTFrador"),
        FilterOption(title: "PitT4BWbull")
    ]

    private var genderOptions: [FilterOption] = [
        FilterOption(title: "Female", isSelected: true),
        FilterOption(title: "Male")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupActions()
        updateCollectionView()
    }

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
        // No need for flowLayoutDelegate
    }

    private func updateCollectionView() {
        let viewModel = makeViewModel()
        driver?.update(viewModel: viewModel, animated: true)
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func resetButtonTapped() {
        // Reset all filters
        FilterManager.shared.selectedPetTypes.removeAll()
        FilterManager.shared.selectedBreeds.removeAll()
        FilterManager.shared.ageRange = (5, 16)
        FilterManager.shared.selectedGender = nil
        FilterManager.shared.isVaccinated = false
        FilterManager.shared.isNeutered = false
        FilterManager.shared.selectedCity = nil
        FilterManager.shared.selectedDistrict = nil

        // Reset options
        petTypeOptions = petTypeOptions.map { FilterOption(title: $0.title, isSelected: false) }
        breedOptions = breedOptions.map { FilterOption(title: $0.title, isSelected: false) }
        genderOptions = genderOptions.map { FilterOption(title: $0.title, isSelected: false) }

        updateCollectionView()
    }

    @objc private func applyButtonTapped() {
        // Save current selections to FilterManager
        // Close the filter view
        dismiss(animated: true)
    }

    private func makeViewModel() -> CollectionViewModel {
        var sections: [SectionViewModel] = []

        // Pet Type Section
        let petTypeCells = petTypeOptions.map { option in
            FilterOptionCellViewModel(option: option, sectionType: .petType).eraseToAnyViewModel()
        }

        let petTypeHeader = FilterHeaderViewModel(title: "Pet Type").eraseToAnyViewModel()

        let petTypeSection = SectionViewModel(
            id: "petTypeSection",
            cells: petTypeCells,
            header: petTypeHeader
        )

        sections.append(petTypeSection)

        // Breed Section
        let breedCells = breedOptions.map { option in
            FilterOptionCellViewModel(option: option, sectionType: .breed).eraseToAnyViewModel()
        }

        let breedHeader = FilterHeaderViewModel(title: "Breed").eraseToAnyViewModel()

        let breedSection = SectionViewModel(
            id: "breedSection",
            cells: breedCells,
            header: breedHeader
        )

        sections.append(breedSection)

        // Gender Section
        let genderCells = genderOptions.map { option in
            FilterOptionCellViewModel(option: option, sectionType: .gender).eraseToAnyViewModel()
        }

        let genderHeader = FilterHeaderViewModel(title: "Gender").eraseToAnyViewModel()

        let genderSection = SectionViewModel(
            id: "genderSection",
            cells: genderCells,
            header: genderHeader
        )

        sections.append(genderSection)

        // Add more sections as needed

        return CollectionViewModel(id: "filterCollectionView", sections: sections)
    }

    // MARK: - CellEventCoordinator

    func didSelectCell(viewModel: any CellViewModel) {
        if let filterOptionVM = viewModel as? FilterOptionCellViewModel {
            // Update the selection state
            switch filterOptionVM.sectionType {
            case .petType:
                if let index = petTypeOptions.firstIndex(where: { $0.title == filterOptionVM.option.title }) {
                    petTypeOptions[index].isSelected.toggle()
                    if petTypeOptions[index].isSelected {
                        FilterManager.shared.selectedPetTypes.insert(petTypeOptions[index].title)
                    } else {
                        FilterManager.shared.selectedPetTypes.remove(petTypeOptions[index].title)
                    }
                }
            case .breed:
                if let index = breedOptions.firstIndex(where: { $0.title == filterOptionVM.option.title }) {
                    breedOptions[index].isSelected.toggle()
                    if breedOptions[index].isSelected {
                        FilterManager.shared.selectedBreeds.insert(breedOptions[index].title)
                    } else {
                        FilterManager.shared.selectedBreeds.remove(breedOptions[index].title)
                    }
                }
            case .gender:
                // For gender, only one can be selected
                genderOptions = genderOptions.map {
                    var option = $0
                    option.isSelected = ($0.title == filterOptionVM.option.title)
                    return option
                }
                FilterManager.shared.selectedGender = filterOptionVM.option.title
            default:
                break
            }
            updateCollectionView()
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
