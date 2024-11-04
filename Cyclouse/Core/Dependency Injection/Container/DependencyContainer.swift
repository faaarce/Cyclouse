//
//  DependencyContainer.swift
//  Cyclouse
//
//  Created by yoga arie on 31/10/24.
//

import Foundation
import Swinject

final class DependencyContainer {
    static let shared = DependencyContainer() // Singleton pattern
    let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        let assembler = Assembler([
            ServicesAssembly(),
            CoordinatorsAssembly(),
            ViewModelsAssembly(),
            RepositoriesAssembly()
        ], container: container)
    }
}
