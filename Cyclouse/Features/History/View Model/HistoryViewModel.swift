//
//  HistoryViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 17/11/24.
//
import UIKit
import Combine
import Foundation

class HistoryViewModel {
    // MARK: - Properties
    
    @Published private(set) var history: [OrderHistory] = []
    @Published private(set) var isLoading: Bool = false
    @Published var error: Error?
    
    private var services = HistoryService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Methods
    
    func fetchHistory() {
        isLoading = true
        services.history()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error
                }
            } receiveValue: { [weak self] historyResponse in
                self?.history = historyResponse.value.data
            }
            .store(in: &cancellables)
    }
}
