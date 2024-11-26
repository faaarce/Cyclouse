//
//  ProfileViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 05/09/24.
//
import UIKit
import SnapKit
import Combine
import Valet

class ProfileViewController: BaseViewController {

    // MARK: - Properties

    var coordinator: ProfileCoordinator
    private var profileData: UserProfiles?
    private let authService = AuthenticationService()
    private let viewModel = ProfileViewModel()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()

    private let profileImageView: UIImageView = {
        let object = UIImageView(image: UIImage(systemName: "person.fill"))
        object.layer.cornerRadius = 50
        object.layer.masksToBounds = true
        object.layer.borderWidth = 3
        object.layer.borderColor = UIColor(hex: "#555555").cgColor
        object.backgroundColor = ThemeColor.cardFillColor
        return object
    }()

    private let cameraButton: UIButton = {
        let object = UIButton(type: .system)
        object.setTitle(nil, for: .normal)
        object.setImage(UIImage(systemName: "camera")?.withRenderingMode(.alwaysTemplate), for: .normal)
        object.tintColor = ThemeColor.primary
        object.layer.cornerRadius = 15
        object.layer.masksToBounds = true
        return object
    }()

    private lazy var profileView: UIView = {
        let object = UIView(frame: .zero)
        object.backgroundColor = ThemeColor.cardFillColor
        object.layer.cornerRadius = 12
        return object
    }()

    private let profileName: UILabel = {
        LabelFactory.build(text: "", font: ThemeFont.semibold(ofSize: 14), textColor: .white)
    }()

    private let profileEmail: UILabel = {
        LabelFactory.build(text: "", font: ThemeFont.medium(ofSize: 10), textColor: ThemeColor.labelColorSecondary)
    }()

    private lazy var menuItems: [UIView] = [
        createPaddedMenuItemStack(title: "My Account", icon: "person", action: #selector(myAccountTapped)),
        createDivider(),
        createPaddedMenuItemStack(title: "Transaction History", icon: "clock.arrow.circlepath", action: #selector(transactionHistoryTapped)),
        createDivider(),
        createPaddedMenuItemStack(title: "Language", icon: "globe"),
        createDivider(),
        createPaddedMenuItemStack(title: "Logout", icon: "questionmark.circle", action: #selector(logoutButtonTapped))
    ]

    // MARK: - Initialization

    init(coordinator: ProfileCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        viewModel.loadUserProfile()
    }

    // MARK: - Setup Methods

    override func setupViews() {
        super.setupViews()
        [profileImageView, cameraButton, profileView, mainStackView, profileName, profileEmail].forEach(view.addSubview)
        view.sendSubviewToBack(profileView)

        menuItems.forEach { mainStackView.addArrangedSubview($0) }
      
      cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
           
           // Load profile image
           loadProfileImage()
    }
  
  private func checkAuthState() {
         print("🔐 Auth State Check:")
         print("Is Logged In:", TokenManager.shared.isLoggedIn())
         print("Current User ID:", TokenManager.shared.getCurrentUserId() ?? "No User ID")
         print("Has Token:", TokenManager.shared.getToken() != nil)
     }
  
  override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    checkAuthState()
        // Configure profileImageView
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
    }

    override func setupConstraints() {
        super.setupConstraints()

        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
        }

        cameraButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.right.equalTo(profileImageView.snp.right)
            $0.bottom.equalTo(profileImageView.snp.bottom)
        }

        profileView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(profileImageView.snp.centerY)
            $0.bottom.equalTo(mainStackView.snp.top).offset(-30)
        }

        profileName.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }

        profileEmail.snp.makeConstraints {
            $0.top.equalTo(profileName.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(profileView.snp.bottom).offset(-20)
        }

        mainStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
    }

    override func bindViewModel() {
        super.bindViewModel()

        viewModel.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                guard let profile = userProfile else { return }
                self?.profileData = profile
                self?.updateUI(with: profile)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func updateUI(with profile: UserProfiles) {
      profileName.text = profile.name
        profileEmail.text = profile.email
        // Update other UI elements if necessary
    }
  
  @objc private func cameraButtonTapped() {
         let picker = UIImagePickerController()
         picker.delegate = self
         picker.sourceType = .photoLibrary
         picker.allowsEditing = true
         present(picker, animated: true)
     }

    private func createMenuItemStack(title: String, icon: String, action: Selector? = nil) -> UIStackView {
        let label = LabelFactory.build(text: title, font: ThemeFont.medium(ofSize: 16), textColor: .white)

        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = ThemeColor.primary
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = ThemeColor.labelColorSecondary
        arrowImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [iconImageView, label, spacerView, arrowImageView])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill

        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        arrowImageView.setContentHuggingPriority(.required, for: .horizontal)

        if let action = action {
            let tapGesture = UITapGestureRecognizer(target: self, action: action)
            stack.addGestureRecognizer(tapGesture)
            stack.isUserInteractionEnabled = true
        }

        return stack
    }

    private func createPaddedMenuItemStack(title: String, icon: String, action: Selector? = nil) -> UIStackView {
        let menuStack = createMenuItemStack(title: title, icon: icon, action: action)
        let paddingStack = UIStackView(arrangedSubviews: [menuStack])
        paddingStack.axis = .vertical
        paddingStack.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        paddingStack.isLayoutMarginsRelativeArrangement = true
        return paddingStack
    }

    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = ThemeColor.cardFillColor
        divider.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        return divider
    }

    // MARK: - Actions

  @objc private func myAccountTapped() {
          guard let profileData = profileData else {
              // Create default profile if none exists
              let defaultProfile = UserProfiles(
                  userId: TokenManager.shared.getCurrentUserId() ?? "",
                  email: "",
                  name: "", phone: ""
              )
              coordinator.showEditProfile(userData: defaultProfile)
              return
          }
          coordinator.showEditProfile(userData: profileData)
      }

    @objc private func transactionHistoryTapped() {
        coordinator.showTransactionHistory()
    }

    private func performLogout() {
        authService.signOut()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    TokenManager.shared.logout()
                    self?.showMessage(
                        title: "Success",
                        body: "Successfully logged out",
                        theme: .success
                    )
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.coordinator.logout()
                    }
                case .failure(let error):
                    self?.showMessage(
                        title: "Error",
                        body: error.localizedDescription,
                        theme: .error
                    )
                }
            } receiveValue: { response in
                print("Logout successful: \(response)")
            }
            .store(in: &cancellables)
    }

    @objc private func logoutButtonTapped() {
        MessageAlert.showConfirmation(
            title: "Logout",
            message: "Are you sure you want to logout?",
            confirmTitle: "Logout",
            cancelTitle: "Cancel",
            onConfirm: { [weak self] in
                self?.performLogout()
            }
        )
    }
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  // MARK: - Image Picker Delegate Methods
 
  func imagePickerController(
         _ picker: UIImagePickerController,
         didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
     ) {
         print("📸 Image picker completed")
         
         // First dismiss the picker to improve UI responsiveness
         picker.dismiss(animated: true)
         
         // Get the selected image
         guard let selectedImage = info[.editedImage] as? UIImage else {
             print("⚠️ No image selected")
             return
         }
         
         guard let userId = TokenManager.shared.getCurrentUserId() else {
             print("⚠️ No user ID available")
             return
         }
         
         print("📱 Selected image size:", selectedImage.size)
         print("👤 Current userId:", userId)
         
         // Show loading indicator
         MessageAlert.showLoading(message: "Updating profile picture...")
         
         // Update UI immediately
         DispatchQueue.main.async { [weak self] in
             guard let self = self else { return }
             print("🔄 Updating UI immediately")
             
             UIView.transition(with: self.profileImageView,
                             duration: 0.3,
                             options: [.transitionCrossDissolve]) {
                 self.profileImageView.image = selectedImage
                 self.profileImageView.contentMode = .scaleAspectFill
             }
             debugImageState()
         }
         
         // Then save in background
         Task {
             do {
                 print("💾 Attempting to save image")
                 try await viewModel.saveProfileImage(selectedImage)
                 print("✅ Image saved successfully")
                 
                 await MainActor.run {
                     MessageAlert.hideLoading()
                     showMessage(
                         title: "Success",
                         body: "Profile picture updated successfully",
                         theme: .success
                     )
                     debugImageState()
                 }
             } catch {
                 print("❌ Failed to save image:", error.localizedDescription)
                 await MainActor.run {
                     MessageAlert.hideLoading()
                     showMessage(
                         title: "Error",
                         body: error.localizedDescription,
                         theme: .error
                     )
                     
                     UIView.transition(with: self.profileImageView,
                                     duration: 0.3,
                                     options: [.transitionCrossDissolve]) {
                         self.profileImageView.image = UIImage(systemName: "person.fill")
                     }
                     debugImageState()
                 }
             }
         }
     }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }
  
  // Add this method to check current state
    private func debugImageState() {
        print("🔍 Debug Image State:")
        print("Is Logged In:", TokenManager.shared.isLoggedIn())
        print("Current User ID:", TokenManager.shared.getCurrentUserId() ?? "No User ID")
        print("Current Image:", profileImageView.image == nil ? "No Image" : "Has Image")
        print("Content Mode:", profileImageView.contentMode.rawValue)
    }
  // MARK: - Helper Methods
   // Update your loadProfileImage method
  private func loadProfileImage() {
      guard let userId = TokenManager.shared.getCurrentUserId() else {
          print("⚠️ No user ID available")
          return
      }
      
      print("📱 Loading profile image for user:", userId)
      
      Task {
          do {
              print("🔄 Attempting to load image...")
              if let image = try await viewModel.loadProfileImage() {
                  print("✅ Image loaded successfully")
                  await MainActor.run {
                      print("🖼 Updating UI with loaded image")
                      UIView.transition(with: self.profileImageView,
                                     duration: 0.3,
                                     options: [.transitionCrossDissolve]) {
                          self.profileImageView.image = image
                          self.profileImageView.contentMode = .scaleAspectFill
                      }
                      debugImageState()
                  }
              } else {
                  print("⚠️ No image returned from loadProfileImage")
              }
          } catch {
              print("❌ Failed to load profile image:", error.localizedDescription)
              await MainActor.run {
                  self.profileImageView.image = UIImage(systemName: "person.fill")
                  debugImageState()
              }
          }
      }
  }
}
