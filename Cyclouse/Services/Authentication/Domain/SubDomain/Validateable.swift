//
//  Validateable.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//

import Foundation

protocol Validateable: Valueable {
  static func validate(_ value: Value) -> ValidationError?
  func validate() -> ValidationError?
}

extension Validateable {
  func validate() -> ValidationError? {
    Self.validate(self.value)
  }
}
