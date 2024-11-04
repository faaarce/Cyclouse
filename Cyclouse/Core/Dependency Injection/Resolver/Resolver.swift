//
//  Resolver.swift
//  Cyclouse
//
//  Created by yoga arie on 31/10/24.
//

import Foundation
import Swinject

import Swinject

protocol DIResolver {
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T
    func resolve<T, Arg1, Arg2>(_ type: T.Type, arguments arg1: Arg1, _ arg2: Arg2) -> T
}

extension Container: DIResolver {
    func resolve<T>(_ type: T.Type) -> T {
        guard let service = resolve(T.self) else {
            fatalError("Could not resolve \(T.self)")
        }
        return service
    }
    
    func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T {
        guard let service = resolve(T.self, argument: argument) else {
            fatalError("Could not resolve \(T.self) with argument \(Arg.self)")
        }
        return service
    }
    
    func resolve<T, Arg1, Arg2>(_ type: T.Type, arguments arg1: Arg1, _ arg2: Arg2) -> T {
        guard let service = resolve(T.self, arguments: arg1, arg2) else {
            fatalError("Could not resolve \(T.self) with arguments \(Arg1.self), \(Arg2.self)")
        }
        return service
    }
}

