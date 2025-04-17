//
//  SignupResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 20/11/24.
//

import Foundation

struct SignupResponse: Responseable {
  let success: Bool
  let message: String
  let userId: String
  let name: String
  let email: String
  let phone: String
}
