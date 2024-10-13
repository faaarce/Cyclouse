//
//  CartNetworkRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 01/10/24.
//

import Foundation
import Combine

class CartNetworkRepository: CartRepository {
  let apiService: APIService
  
  init(apiService: APIService = APIManager()) {
    self.apiService = apiService
  }
  
  func addToCart(productId: String, quantity: Int) -> AnyPublisher<APIResponse<AddToCartResponse>, Error> {
    apiService.request(CartAPI.addToCart(productId: productId, quantity: quantity), includeHeaders: true)
  }
  
  func getCart() -> AnyPublisher<APIResponse<GetCartResponse>, Error> {
    apiService.request(CartAPI.getCart, includeHeaders: true)
  }
}
