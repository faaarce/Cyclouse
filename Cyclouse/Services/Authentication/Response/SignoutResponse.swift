//
//  SignoutResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 08/10/24.
//

import Foundation

struct SignoutResponse: Responseable {
  let success: Bool
  let message: String
  let userId: String
  let name: String
  let email: String
  let phone: String
}
