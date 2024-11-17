//
//  ProfileViewModel.swift
//  Cyclouse
//
//  Created by yoga arie on 17/11/24.
//
import Foundation
import Combine
import Valet

class ProfileViewModel {

    // MARK: - Properties

    private let valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!, accessibility: .whenUnlocked)
    private let userProfileSubject = CurrentValueSubject<UserProfile?, Never>(nil)
    var userProfilePublisher: AnyPublisher<UserProfile?, Never> {
        userProfileSubject.eraseToAnyPublisher()
    }

    // MARK: - Methods

    func loadUserProfile() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let profileData = try self.valet.object(forKey: "userProfile")
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: profileData)
                self.userProfileSubject.send(userProfile)
            } catch {
                print("Failed to load user profile: \(error)")
                self.userProfileSubject.send(nil)
            }
        }
    }

    // Add methods to update the profile if needed
}
