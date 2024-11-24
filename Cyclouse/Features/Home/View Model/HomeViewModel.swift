import Foundation
import Combine
import ReactiveCollectionsKit

class HomeViewModel {
    // MARK: - Properties
    private let service: DatabaseService
    private let bikeService: BikeService
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var isLoading = true
    @Published private(set) var categories: [Category] = []
    @Published private(set) var filteredCategories: [Category]? = nil
    @Published private(set) var searchResults: [Product] = []
    @Published private(set) var selectedCategory: String? = nil
    @Published private(set) var cartItemCount: Int = 0
    
    let allCategories = ["All", "Full Bike", "Handlebar", "Saddle", "Pedal", "Seatpost", "Stem", "Crank", "Wheelset", "Frame", "Tires"]
    
    var allProducts: [Product] {
        return categories.flatMap { $0.products }
    }
    
    // MARK: - Initialization
    
    init(service: DatabaseService = .shared, bikeService: BikeService = BikeService()) {
        self.service = service
        self.bikeService = bikeService
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        simulateLoading()
    }
    
    func viewWillAppear() {
        updateCartBadge()
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category != "All" ? category : nil
        if selectedCategory == nil {
            filteredCategories = nil
        }
    }
    
    func search(with query: String) {
        if query.isEmpty {
            searchResults = []
        } else {
            searchResults = allProducts.filter { product in
                product.name.lowercased().contains(query.lowercased())
            }
        }
    }
    
    func applyFilters() {
        let filterManager = FilterManager.shared
        
        let filtered = categories.compactMap { category -> Category? in
            if !filterManager.selectedCategories.isEmpty &&
               !filterManager.selectedCategories.contains(category.categoryName) {
                return nil
            }
            
            let filteredProducts = category.products.filter { product in
                if !filterManager.selectedBrands.isEmpty &&
                   !filterManager.selectedBrands.contains(product.brand) {
                    return false
                }
                
                if product.price < filterManager.priceRange.min ||
                   product.price > filterManager.priceRange.max {
                    return false
                }
                
                return true
            }
            
            guard !filteredProducts.isEmpty else { return nil }
            
            let sortedProducts = sortProducts(filteredProducts, by: filterManager.sortBy)
            
            return Category(categoryName: category.categoryName, products: sortedProducts)
        }
        
        // Only set filteredCategories if filters are actually applied
        if filterManager.selectedCategories.isEmpty &&
           filterManager.selectedBrands.isEmpty &&
           filterManager.priceRange == (0, 30_000_000) &&
           filterManager.sortBy == .nameAsc {
            filteredCategories = nil
        } else {
            filteredCategories = filtered
        }
    }
    
    func makeCollectionViewModel() -> CollectionViewModel {
        var sections: [SectionViewModel] = []
        
        if !searchResults.isEmpty {
            // Search Results Section
            let productCellViewModels = searchResults.map {
                BikeProductCellViewModel(product: $0, categoryName: $0.brand).eraseToAnyViewModel()
            }
            
            let searchResultsSection = SectionViewModel(
                id: "search_results",
                cells: productCellViewModels
            )
            
            sections.append(searchResultsSection)
            
        } else {
            // Categories Section
            let categoryCellViewModels = allCategories.map { categoryName in
                let isSelected = (categoryName == selectedCategory) || (selectedCategory == nil && categoryName == "All")
                return CategoryCellViewModel(category: categoryName, isSelected: isSelected).eraseToAnyViewModel()
            }
            
            let categorySectionHeader = SectionHeaderViewModel(
                id: "header_categories",
                title: "Categories"
            )
            
            let categorySection = SectionViewModel(
                id: "section_categories",
                cells: categoryCellViewModels,
                header: categorySectionHeader.eraseToAnyViewModel()
            )
            
            sections.append(categorySection)
            
            if isLoading {
                // Loading Placeholders
                sections.append(contentsOf: createLoadingPlaceholders())
            } else {
                // Product Sections
                let dataToUse = filteredCategories ?? categories
                let filteredData = selectedCategory != nil ?
                    dataToUse.filter { $0.categoryName == selectedCategory } :
                    dataToUse
                
                sections.append(contentsOf: createProductSections(from: filteredData))
            }
        }
        
        return CollectionViewModel(
            id: "main_collection",
            sections: sections
        )
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        NotificationCenter.default.publisher(for: NSNotification.Name("FilterSettingsChanged"))
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    private func simulateLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isLoading = false
            self?.fetchBikes()
        }
    }
    
    private func fetchBikes() {
        bikeService.getBikes()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error fetching bikes: \(error)")
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] bikeDataResponse in
                self?.categories = bikeDataResponse.value.bikes.categories
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    private func updateCartBadge() {
        service.fetchBike()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching bike items: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] bike in
                self?.cartItemCount = bike.count
            }
            .store(in: &cancellables)
    }
    
    private func sortProducts(_ products: [Product], by sortBy: SortOption) -> [Product] { //ERROR: -'SortOption' is not a member type of class 'Cyclouse.FilterManager'
        switch sortBy {
        case .nameAsc:
            return products.sorted { $0.name < $1.name }
        case .nameDesc:
            return products.sorted { $0.name > $1.name }
        case .priceLowToHigh:
            return products.sorted { $0.price < $1.price }
        case .priceHighToLow:
            return products.sorted { $0.price > $1.price }
        }
    }
    
    private func createLoadingPlaceholders() -> [SectionViewModel] {
        let placeholderCategoryNames = ["Loading Category 1", "Loading Category 2", "Loading Category 3"]
        
        return placeholderCategoryNames.map { categoryName in
            let loadingHeader = SectionHeaderViewModel(
                id: "loading_header_\(categoryName)",
                isLoading: true
            )
            
            let placeholderCells = (0..<5).map { _ in
                BikeProductCellViewModel(isLoading: true).eraseToAnyViewModel()
            }
            
            return SectionViewModel(
                id: "loading_section_\(categoryName)",
                cells: placeholderCells,
                header: loadingHeader.eraseToAnyViewModel()
            )
        }
    }
    
    private func createProductSections(from categories: [Category]) -> [SectionViewModel] {
        return categories.map { category in
            let productCellViewModels = category.products.map {
                BikeProductCellViewModel(product: $0, categoryName: category.categoryName).eraseToAnyViewModel()
            }
            
            let productSectionHeader = SectionHeaderViewModel(
                id: "header_\(category.categoryName)",
                title: category.categoryName
            )
            
            return SectionViewModel(
                id: "section_\(category.categoryName)",
                cells: productCellViewModels,
                header: productSectionHeader.eraseToAnyViewModel()
            )
        }
    }
}



