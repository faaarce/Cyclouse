//
//  CoreDataManager.swift
//  TaskManagement
//
//  Created by Phincon on 18/07/24.
//

import CoreData
import Foundation

class CoreDataManager {
  
  static let shared = CoreDataManager()
  private init() {}
  private let persistanceName: String = "TaskModel"
  
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: persistanceName)
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        print("Unresolved error \\(error), \\(error.userInfo)")
      }
    }
    return container
  }()
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  func saveContext() throws {
    if context.hasChanges {
      try context.save()
    }
  }
}
