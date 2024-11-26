//
//  BaseViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 16/11/24.
//

import UIKit
import Combine
import SwiftMessages
import SnapKit
import Valet

/// A base view controller that provides common functionality for all view controllers in the app.
class BaseViewController: UIViewController {
    
    // MARK: - Properties
    
    /// A set to hold Combine cancellables for memory management.
    var cancellables = Set<AnyCancellable>()
    
    /// A Valet instance for secure data storage.
    let valet = Valet.valet(with: Identifier(nonEmpty: "com.yourapp.auth")!, accessibility: .whenUnlocked)
    
    /// Indicates whether the view controller is currently loading data.
    var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }
    
    // MARK: - Initialization
    
    /// Initializes a new instance of the base view controller.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Required initializer for decoding from storyboard (not used).
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseConfiguration()
        setupViews()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - Setup Methods
    
    /// Configures the base settings for the view controller.
     func setupBaseConfiguration() {
        view.backgroundColor = ThemeColor.background
        setupNavigationBarAppearance()
    }
    
    /// Configures the navigation bar appearance.
    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.tintColor = ThemeColor.primary
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: ThemeFont.medium(ofSize: 16)
        ]
    }
    
    /// Sets up the views. Override this method in subclasses to add subviews.
    func setupViews() {
        // Subclasses implement this method to add subviews.
    }
    
    /// Sets up the constraints. Override this method in subclasses to add constraints.
    func setupConstraints() {
        // Subclasses implement this method to set up constraints.
    }
    
    /// Binds the view model to the view. Override this method in subclasses.
    func bindViewModel() {
        // Subclasses implement this method to bind view models.
    }
    
    // MARK: - Loading State Methods
    
    /// Updates the UI based on the loading state. Override in subclass if needed.
    func updateLoadingState() {
        // Subclasses can override this method to update the UI when loading state changes.
    }
    
    // MARK: - Message Display
    
    /// Displays a message using SwiftMessages.
    ///
    /// - Parameters:
    ///   - title: The title of the message.
    ///   - body: The body text of the message.
    ///   - theme: The theme of the message (default is `.info`).
    ///   - backgroundColor: Optional custom background color.
    ///   - foregroundColor: Optional custom text color.
    ///   - duration: Duration in seconds for which the message is displayed (default is 3 seconds).
    func showMessage(title: String,
                     body: String,
                     theme: Theme = .info,
                     backgroundColor: UIColor? = nil,
                     foregroundColor: UIColor? = nil,
                     duration: TimeInterval = 3) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(theme)
        view.configureDropShadow()
        
        if let backgroundColor = backgroundColor {
            view.backgroundColor = backgroundColor
        }
        
        if let foregroundColor = foregroundColor {
            view.titleLabel?.textColor = foregroundColor
            view.bodyLabel?.textColor = foregroundColor
        }
        
        view.configureContent(title: title, body: body)
        view.button?.isHidden = true
        
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: duration)
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = true
        
        SwiftMessages.show(config: config, view: view)
    }
    
    // MARK: - Alert Display
    
    /// Displays an alert with optional primary and secondary actions.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message body of the alert.
    ///   - primaryAction: The primary action button (optional).
    ///   - secondaryAction: The secondary action button (optional).
    func showAlert(title: String,
                   message: String,
                   primaryAction: UIAlertAction? = nil,
                   secondaryAction: UIAlertAction? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let primaryAction = primaryAction {
            alert.addAction(primaryAction)
        }
        
        if let secondaryAction = secondaryAction {
            alert.addAction(secondaryAction)
        }
        
        if primaryAction == nil && secondaryAction == nil {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Skeleton Loading
    
    /// Configures views to be skeletonable.
    ///
    /// - Parameter views: An array of views to be configured.
    func configureSkeletonableViews(_ views: [UIView]) {
        views.forEach { view in
            view.isSkeletonable = true
            if let label = view as? UILabel {
                label.linesCornerRadius = 8
            }
        }
    }
    
    /// Shows skeleton loading animation on the specified views.
    ///
    /// - Parameter views: An array of views to show skeleton loading on.
    func showSkeletonLoading(in views: [UIView]) {
        views.forEach { view in
            view.showAnimatedGradientSkeleton()
        }
    }
    
    /// Hides skeleton loading animation from the specified views.
    ///
    /// - Parameter views: An array of views to hide skeleton loading from.
    func hideSkeletonLoading(in views: [UIView]) {
        views.forEach { view in
            view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        }
    }
    
    // MARK: - Generic Error Handling
    
    /// Handles errors by displaying an error message.
    ///
    /// - Parameter error: The error to handle.
    func handleError(_ error: Error) {
        showMessage(
            title: "Error",
            body: error.localizedDescription,
            theme: .error
        )
    }
    
    // MARK: - User Profile Handling
    
    /// Loads the user profile using Valet.
    ///
    /// - Returns: An optional `UserProfile` if available.
    func loadUserProfile() -> UserProfiles? {
        do {
            let profileData = try valet.object(forKey: "userProfile")
            let userProfile = try JSONDecoder().decode(UserProfiles.self, from: profileData)
            return userProfile
        } catch {
            print("Failed to load user profile: \(error)")
            return nil
        }
    }
    
    // MARK: - Notification Handling
    
    /// Adds an observer for a specific notification.
    ///
    /// - Parameters:
    ///   - name: The name of the notification to observe.
    ///   - selector: The selector to call when the notification is received.
    func addObserver(forName name: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    /// Removes all observers for the view controller.
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Memory Management
    
    deinit {
        cancellables.removeAll()
        removeObservers()
    }
}

// MARK: - ViewModel Binding Protocol

/// A protocol for view controllers that bind to a view model.
protocol ViewModelBindable {
    associatedtype ViewModel
    var viewModel: ViewModel { get }
    func bindViewModel()
}

// MARK: - Skeleton Loading Protocol

/// A protocol for views that support skeleton loading.
protocol SkeletonLoadable {
    /// An array of views that can show skeleton loading.
    var skeletonableViews: [UIView] { get }
    
    /// Shows skeleton loading.
    func showSkeleton()
    
    /// Hides skeleton loading.
    func hideSkeleton()
}

extension SkeletonLoadable where Self: BaseViewController {
    func showSkeleton() {
        showSkeletonLoading(in: skeletonableViews)
    }
    
    func hideSkeleton() {
        hideSkeletonLoading(in: skeletonableViews)
    }
}

