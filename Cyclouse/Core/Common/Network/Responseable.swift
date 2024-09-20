//
//  Responseable.swift
//  PetCenter
//
//  Created by Phincon on 01/07/24.
//

public protocol Responseable: Decodable {
  var message: String { get }
  var success: Bool { get }
}
