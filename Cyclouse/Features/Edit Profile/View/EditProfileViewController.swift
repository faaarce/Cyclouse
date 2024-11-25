//
//  EditProfileViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 25/11/24.
//

import UIKit
import SnapKit


class EditProfileViewController: BaseViewController {
    
    // MARK: - Properties
    private var userData: UserProfile
    var coordinator: EditProfileCoordinator
    
    // MARK: - UI Components
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.backgroundColor = .clear
        return stack
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.cardFillColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    // Field Views
  private lazy var fullNameField = createProfileField(title: "Full Name", value: userData.name)
   private lazy var phoneField = createProfileField(title: "Phone Number", value: userData.name)
  private lazy var emailField = createProfileField(title: "Email", value: userData.email)
   private lazy var addressField = createProfileField(title: "Address", value: userData.name)
   
    
    // MARK: - Initialization
    init(coordinator: EditProfileCoordinator, userData: UserProfile) {
        self.userData = userData
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureNavigationBar()
    }
    
    // MARK: - Setup Methods
    override func setupViews() {
        title = "Profile"
        view.backgroundColor = ThemeColor.background
        
        view.addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        [fullNameField, phoneField, emailField, addressField].forEach { field in
            mainStackView.addArrangedSubview(field)
        }
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }
    
    // MARK: - Helper Methods
    private func createProfileField(title: String, value: String) -> UIView {
        let containerView = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        let titleLabel = LabelFactory.build(
            text: title,
            font: ThemeFont.semibold(ofSize: 14),
            textColor: ThemeColor.labelColorSecondary,
            textAlignment: .left
        )
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueLabel = LabelFactory.build(
            text: value,
            font: ThemeFont.semibold(ofSize: 14),
            textColor: .white
        )
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.textAlignment = .right
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
        
        // Add bottom border
        let borderView = UIView()
        borderView.backgroundColor = ThemeColor.labelColorSecondary.withAlphaComponent(0.3)
        containerView.addSubview(borderView)
        
        borderView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        // Handle edit action
        print("Edit button tapped")
    }
}
