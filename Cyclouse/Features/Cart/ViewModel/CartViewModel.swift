//
//  CartViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 14/11/24.
//

import Combine
import UIKit

class CartViewModel {
    // MARK: - Properties

    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()

    // Published properties
    @Published var bikeData: [BikeDatabase] = []
    @Published var selectedStates: [String: Bool] = [:]
    @Published var isAllSelected: Bool = true
    @Published var totalPrice: Double = 0.0

    // Delegate for updating badge count
    var delegate: OrderBadgesUpdateDelegate?

    // Methods
    init() {
        fetchBikes()
    }
  
  func removeSelectedBikes() -> AnyPublisher<Void, Error> {
      // Get selected bikes
      let selectedBikes = bikeData.filter { bike in
          selectedStates[bike.id] ?? false
      }
      
      // Create a publisher array for all delete operations
      let deleteOperations = selectedBikes.map { bike in
          databaseService.delete(bike)
      }
      
      // Combine all delete operations into a single publisher
      return Publishers.MergeMany(deleteOperations)
          .collect()
          .map { _ in () }
          .eraseToAnyPublisher()
  }

    func fetchBikes() {
        databaseService.fetchBike()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    // Handle error (you can add error handling here)
                    print("Error fetching bikes: \(error)")
                }
            } receiveValue: { [weak self] bikes in
                guard let self = self else { return }

                // Update bikeData
                self.bikeData = bikes

                // Update selectedStates
                var newSelectedStates = self.selectedStates
                for bike in bikes {
                    if newSelectedStates[bike.id] == nil {
                        newSelectedStates[bike.id] = true // Default new bikes to selected
                    }
                }
                // Remove selection states for bikes no longer in cart
                let bikeIds = Set(bikes.map { $0.id })
                newSelectedStates = newSelectedStates.filter { bikeIds.contains($0.key) }
                self.selectedStates = newSelectedStates

                // Update isAllSelected
                self.isAllSelected = !self.selectedStates.values.contains(false)

                // Update total price
                self.updateTotalPrice()

                // Update badge number
                self.delegate?.updateBadge(badgeNumber: bikes.count)
            }
            .store(in: &cancellables)
    }

    func updateBikeQuantity(_ bike: BikeDatabase, newQuantity: Int) {
        databaseService.updateBikeQuantity(bike, newQuantity: newQuantity)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    // Handle error (you can add error handling here)
                    print("Error updating bike quantity: \(error)")
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                if let index = self.bikeData.firstIndex(where: { $0.id == bike.id }) {
                    self.bikeData[index].cartQuantity = newQuantity
                    // Update total price
                    self.updateTotalPrice()
                }
            }
            .store(in: &cancellables)
    }

    func deleteBike(_ bike: BikeDatabase) {
        databaseService.delete(bike)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                  guard let self = self else { return }
                                 // Remove the bike from bikeData
                                 self.bikeData.removeAll { $0.id == bike.id }
                                 // Remove from selectedStates
                                 self.selectedStates[bike.id] = nil
                                 // Update total price
                                 self.updateTotalPrice()
                                 // Notify delegate to update badge if needed
                                 self.delegate?.updateBadge(badgeNumber: self.bikeData.count)
                case .failure(let error):
                    // Handle error (you can add error handling here)
                    print("Error deleting bike: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func toggleSelection(for bike: BikeDatabase) {
        if let currentSelection = selectedStates[bike.id] {
            selectedStates[bike.id] = !currentSelection
        } else {
            selectedStates[bike.id] = true
        }
        // Update isAllSelected
        isAllSelected = !selectedStates.values.contains(false)
        // Update total price
        updateTotalPrice()
    }

    func toggleSelectAll() {
        isAllSelected.toggle()
        for bike in bikeData {
            selectedStates[bike.id] = isAllSelected
        }
        // Update total price
        updateTotalPrice()
    }

    func updateTotalPrice() {
        var total: Double = 0.0
        for bike in bikeData {
            if selectedStates[bike.id] ?? false {
                total += Double(bike.price) * Double(bike.cartQuantity)
            }
        }
        totalPrice = total
    }
}
