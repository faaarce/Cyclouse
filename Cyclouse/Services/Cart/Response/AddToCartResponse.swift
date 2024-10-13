//
//  AddToCartResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 01/10/24.
//

import Foundation


struct AddToCartResponse: Responseable {
  var success: Bool
  
    let message: String
    let data: CartData
}
