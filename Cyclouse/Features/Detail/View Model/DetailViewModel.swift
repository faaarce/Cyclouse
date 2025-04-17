//
//  DetailViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 31/10/24.
//

import Foundation
import Combine

// MARK: - DetailViewModel
class DetailViewModel {
    // MARK: - Properties
    let product: Product
    private let cartService: CartService
    private let databaseService: DatabaseService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    @Published var isLoading = true
    @Published var showError: (title: String, message: String)?
    @Published var showSuccess: (title: String, message: String)?
    
    // MARK: - Initialization
    init(product: Product,
         cartService: CartService,
         databaseService: DatabaseService = DatabaseService.shared) {
        self.product = product
        self.cartService = cartService
        self.databaseService = databaseService
    }
    
    // MARK: - Public Methods
    var productName: String {
        product.name
    }
    
    var productPrice: String {
        product.price.toRupiah()
    }
    
    var productDescription: String {
        product.description
    }
    
    var productImages: [String] {
        product.images
    }
    
    var productId: String {
        product.id
    }
    
    func addToCart() {
        let bikeProduct = BikeDatabase(
            name: product.name,
            price: product.price,
            brand: product.brand,
            images: product.images,
            descriptions: product.description,
            stockQuantity: product.quantity,
            productId: product.id
        )
        
      databaseService.addBikeToCart(bikeProduct)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.showError = ("Error", "Failed to add bike item: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] response in
                  print("Add to cart successful: \(response)")
                    self?.showSuccess = ("Success", "Bike item added to cart")
                }
                .store(in: &cancellables)
        }
}
