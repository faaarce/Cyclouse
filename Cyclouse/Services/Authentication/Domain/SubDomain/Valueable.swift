//
//  Valueable.swift
//  FoodApp
//
//  Created by Phincon on 16/07/24.
//

protocol Valueable {
  associatedtype Value
  var value: Value { get }
  init(_ value: Value) throws
}
