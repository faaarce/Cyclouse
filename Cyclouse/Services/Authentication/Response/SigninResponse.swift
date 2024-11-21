//
//  SigninResponse.swift
//  exercise4
//
//  Created by Phincon on 15/07/24.
//

struct SignInResponse: Responseable {
  let success: Bool
  let message: String
  let userId: String
  let name: String
}
