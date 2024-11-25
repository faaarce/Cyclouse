//
//  EditProfileResponse.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//

import Foundation

struct EditProfileResponse: Responseable {
  var message: String
  var success: Bool
  var data: UserData
}

struct UserData: Codable {
  var id: String
  var name: String
  var email: String
  var phone: String
  var password: String
}
