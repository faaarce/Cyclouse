//
//  DatabaseService.swift
//  Exercise
//
//  Created by yoga arie on 20/07/24.
//
import Foundation
import SwiftData
import Combine

enum DatabaseError: Error {
    case contextNotFound
    case fetchFailed
    case saveFailed
    case deleteFailed
}

class DatabaseService {
    static let shared = DatabaseService()
    private var container: ModelContainer?
    private var context: ModelContext?
    
    // Combine publishers
    let databaseUpdated = PassthroughSubject<Void, Never>()
    
    private init() {
        setupContainer()
    }
    
    private func setupContainer() {
        do {
          let schema = Schema([BikeProduct.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            if let container = container {
                context = ModelContext(container)
            }
        } catch {
            print("Failed to setup container: \(error)")
        }
    }
    
    // Generic create method
    func create<T: PersistentModel>(_ object: T) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self, let context = self.context else {
                    promise(.failure(DatabaseError.contextNotFound))
                    return
                }
                context.insert(object)
                do {
                    try self.saveContext()
                    self.databaseUpdated.send()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Generic fetch method
    func fetch<T: PersistentModel>(_ type: T.Type, sortBy: SortDescriptor<T>? = nil, predicate: Predicate<T>? = nil) -> AnyPublisher<[T], Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self, let context = self.context else {
                    promise(.failure(DatabaseError.contextNotFound))
                    return
                }
                var descriptor = FetchDescriptor<T>()
                if let sortBy = sortBy {
                    descriptor.sortBy = [sortBy]
                }
                if let predicate = predicate {
                    descriptor.predicate = predicate
                }
                do {
                    let results = try context.fetch(descriptor)
                    promise(.success(results))
                } catch {
                    promise(.failure(DatabaseError.fetchFailed))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Generic update method
    func update<T: PersistentModel>(_ object: T, with updateClosure: @escaping (T) -> Void) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else {
                    promise(.failure(DatabaseError.contextNotFound))
                    return
                }
                updateClosure(object)
                do {
                    try self.saveContext()
                    self.databaseUpdated.send()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Generic delete method
    func delete<T: PersistentModel>(_ object: T) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self, let context = self.context else {
                    promise(.failure(DatabaseError.contextNotFound))
                    return
                }
                context.delete(object)
                do {
                    try self.saveContext()
                    self.databaseUpdated.send()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Generic delete all method
    func deleteAll<T: PersistentModel>(_ type: T.Type) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self, let context = self.context else {
                    promise(.failure(DatabaseError.contextNotFound))
                    return
                }
                do {
                    try context.delete(model: T.self)
                    try self.saveContext()
                    self.databaseUpdated.send()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Save context method
    private func saveContext() throws {
        guard let context = context else { throw DatabaseError.contextNotFound }
        do {
            try context.save()
        } catch {
            throw DatabaseError.saveFailed
        }
    }
    
    // Specific methods for Food and History
  func saveBike(_ bike: BikeProduct) -> AnyPublisher<Void, Error> {
        create(bike)
    }
    
    func saveHistory(_ history: [History]) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self, let context = self.context else {
                    promise(.failure(DatabaseError.contextNotFound))
                    return
                }
                for item in history {
                    context.insert(item)
                }
                do {
                    try self.saveContext()
                    self.databaseUpdated.send()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
  func fetchBike() -> AnyPublisher<[BikeProduct], Error> {
    fetch(BikeProduct.self, sortBy: SortDescriptor<BikeProduct>(\.time))
    }
    
    func fetchHistory() -> AnyPublisher<[History], Error> {
        fetch(History.self, sortBy: SortDescriptor<History>(\.time))
    }
    
    func deleteAllBike() -> AnyPublisher<Void, Error> {
      deleteAll(BikeProduct.self)
    }
    
  func deleteFood(_ bike: BikeProduct) -> AnyPublisher<Void, Error> {
        delete(bike)
    }
}
