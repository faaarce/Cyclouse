//
//  PopUpViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 14/09/24.
//

import UIKit

class PopUpViewController: UIViewController {
  
  // 1
  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 16
    view.clipsToBounds = true
    view.backgroundColor = UIColor(hex: "F8EDDC", alpha: 1.0)
    return view
  }()
  
  // 2
  let maxDimmedAlpha: CGFloat = 0.6
  lazy var dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.alpha = maxDimmedAlpha
    return view
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "You Place The Order Successfully"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 20, weight: .thin)
    label.textColor = UIColor(hex: "010F07", alpha: 1.0)
    label.numberOfLines = 2
    label.font = .boldSystemFont(ofSize: 20)
    return label
  }()
  
  lazy var notesLabel: UILabel = {
    let label = UILabel()
    label.text = "You placed the order successfully. You will get your food within minutes. Thanks for using our services. Enjoy your food :)"
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 16)
    label.textColor = UIColor(hex: "868686", alpha: 1.0)
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }()
  
  lazy var checkImage: UIImageView = {
    let image = UIImageView(frame: .zero)
    image.contentMode = .scaleAspectFit
    image.image = UIImage(systemName: "checkmark.circle.fill")
    image.tintColor = UIColor(hex: "F8B64C", alpha: 1.0)
    return image
  }()
  
  lazy var contentStackView: UIStackView = {
    let spacer = UIView()
    let stackView = UIStackView(arrangedSubviews: [titleLabel, notesLabel, keepBrowsingButton])
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.spacing = 12.0
    return stackView
  }()
  
  lazy var keepBrowsingButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("KEEP BROWSING", for: .normal)
    
    
    button.setTitleColor(UIColor(hex: "EEA734", alpha: 1.0), for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    button.layer.cornerRadius = 20
    button.clipsToBounds = false
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 10)
    button.layer.shadowRadius = 5
    button.layer.shadowOpacity = 0.3
    return button
  }()
  
  let defaultHeight: CGFloat = 300
  
  // 3. Dynamic container constraint
  var containerViewHeightConstraint: NSLayoutConstraint?
  var containerViewBottomConstraint: NSLayoutConstraint?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupConstraints()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeController)))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 0.3) {
      self.containerViewBottomConstraint?.constant = 0
      self.view.layoutIfNeeded()
    }
  }
  
  
  @objc
  func closeController() {
    self.dismiss(animated: false)
  }
  
  func setupView() {
    view.backgroundColor = .clear
  }
  
  func setupConstraints() {
    // 4. Add subviews
    view.addSubview(dimmedView)
    view.addSubview(containerView)
    view.addSubview(checkImage)
    checkImage.translatesAutoresizingMaskIntoConstraints = false
    dimmedView.translatesAutoresizingMaskIntoConstraints = false
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(contentStackView)
    contentStackView.translatesAutoresizingMaskIntoConstraints = false
    
    // 5. Set static constraints
    NSLayoutConstraint.activate([
      // set dimmedView edges to superview
      
      contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
      contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
      contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
      dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      // set container static constraint (trailing & leading)
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
      checkImage.centerYAnchor.constraint(equalTo: containerView.topAnchor),
      checkImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      checkImage.widthAnchor.constraint(equalToConstant: 70),
      checkImage.heightAnchor.constraint(equalToConstant: 70)
      
    ])
    
    // 6. Set container to default height
    containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
    // 7. Set bottom constant to 0
    containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 300)
    // Activate constraints
    containerViewHeightConstraint?.isActive = true
    containerViewBottomConstraint?.isActive = true
    
  }
}
