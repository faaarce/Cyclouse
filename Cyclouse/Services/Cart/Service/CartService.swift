//
//  CartService.swift
//  Cyclouse
//
//  Created by yoga arie on 01/10/24.
//

import Foundation
import Combine

struct CartService {
    let repository: CartRepository
    
    init(repository: CartRepository = CartNetworkRepository()) {
        self.repository = repository
    }
    
    func addToCart(productId: String, quantity: Int) -> AnyPublisher<APIResponse<AddToCartResponse>, Error> {
        return repository.addToCart(productId: productId, quantity: quantity).eraseToAnyPublisher()
    }
  
  func getCart() -> AnyPublisher<APIResponse<GetCartResponse>, Error> {
    return repository.getCart().eraseToAnyPublisher()
  }
}

