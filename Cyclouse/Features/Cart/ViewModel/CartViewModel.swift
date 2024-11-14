//
//  CartViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 14/11/24.
//

import Combine
import UIKit

class CartViewModel {
  
  // MARK: - Published Properties
  @Published var bikeData: [BikeDatabase] = []
  @Published var selectedStates: [String: Bool] = [:]
  @Published var isAllSelected: Bool = true
  @Published var totalPrice: Double = 0.0
  
  // MARK: - Dependencies
  private let databaseService: DatabaseServiceProtocol
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Initializer
  init(databaseService: DatabaseServiceProtocol = DatabaseService.shared) {
    self.databaseService = databaseService
    fetchBikes()
    setupBindings()
  }
  
  // MARK: - Methods
  private func fetchBikes() {
    databaseService.fetchBike()
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          print("Error fetching bikes: \(error)")
        }
      } receiveValue: { [weak self] bikes in
        guard let self = self else { return }
        self.bikeData = bikes
        self.updateSelectedStates(with: bikes)
        self.updateTotalPrice()
      }
      .store(in: &cancellables)

  }
  
  private func updateSelectedStates(with bikes: [BikeDatabase]) {
    var newSelectedStates = self.selectedStates
    for bike in bikes {
      if newSelectedStates[bike.id] == nil {
        newSelectedStates[bike.id] = true
      }
    }
    
    let bikeIds = Set(bikes.map { $0.id })
    newSelectedStates = newSelectedStates.filter { bikeIds.contains($0.key) }
    self.selectedStates = newSelectedStates
    
    self.isAllSelected = !self.selectedStates.values.contains(false)
  }
  
  private func setupBindings() {
    Publishers.CombineLatest($selectedStates, $bikeData)
      .sink { [weak self] _, _ in
        self?.updateTotalPrice()
      }
      .store(in: &cancellables)
  }
  
  private func updateTotalPrice() {
    var total: Double = 0.0
    for bike in bikeData {
      if selectedStates[bike.id] ?? false {
        total += Double(bike.price) * Double(bike.cartQuantity)
      }
    }
    self.totalPrice = total
  }
  
  func updateBikeQuantity(_ bike: BikeDatabase, newQuantity: Int) {
    databaseService.updateBikeQuantity(bike, newQuantity: newQuantity)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          print("Error update bike quantity: \(error)")
        }
      } receiveValue: { [weak self] _ in
        guard let self = self else { return }
        if let index = self.bikeData.firstIndex(where: { $0.id == bike.id }) {
          self.bikeData[index].cartQuantity = newQuantity
          self.bikeData = self.bikeData
        }
      }
      .store(in: &cancellables)

  }
  
  func toggleSelectAll() {
    isAllSelected.toggle()
    for bike in bikeData {
      selectedStates[bike.id] = isAllSelected
    }
  }
  
  func toggleSelection(for bikeID: String) {
    if let currentState = selectedStates[bikeID] {
      selectedStates[bikeID] = !currentState
      isAllSelected = !selectedStates.values.contains(false)
    }
  }
  
  func deleteBike(at indexPath: IndexPath) {
    let bikeToDelete = bikeData[indexPath.row]
    databaseService.delete(bikeToDelete)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          print("Error deleting bike: \(error)")
        }
      } receiveValue: { [weak self] _ in
        self?.fetchBikes()
      }
      .store(in: &cancellables)

  }
  
  func getSelectedBikes() -> [BikeDatabase] {
    return bikeData.filter { selectedStates[$0.id] ?? false }
  }
  
}

