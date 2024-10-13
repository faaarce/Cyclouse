//
//  CartRepository.swift
//  Cyclouse
//
//  Created by yoga arie on 01/10/24.
//

import Foundation
import Combine

protocol CartRepository {
    func addToCart(productId: String, quantity: Int) -> AnyPublisher<APIResponse<AddToCartResponse>, Error>
  func getCart() -> AnyPublisher<APIResponse<GetCartResponse>, Error>
}
