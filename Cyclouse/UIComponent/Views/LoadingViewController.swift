//
//  LoadingsViewController.swift
//  Cyclouse
//
//  Created by yoga arie on 22/09/24.
//
import SnapKit
import UIKit

class LoadingViewController: UIViewController {
    
    private let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    private let containerView = UIView()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()
    
    private let activityIndicatorContainer = UIView()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        return indicator
    }()
    
    private let messageLabel: UILabel = {
      LabelFactory.build(text: "Loading...", font: ThemeFont.medium(ofSize: 16), textColor: ThemeColor.primary, textAlignment: .center)
    }()
    
    var message: String? {
        didSet {
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    private func setupViews() {
        view.addSubview(visualEffectView)
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(activityIndicatorContainer)
        activityIndicatorContainer.addSubview(activityIndicator)
        stackView.addArrangedSubview(messageLabel)
    }
    
    private func setupConstraints() {
        visualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        
        activityIndicatorContainer.snp.makeConstraints { make in
            make.size.equalTo(100)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(activityIndicatorContainer)
        }
    }
    
    private func update() {
        if isViewLoaded {
            messageLabel.text = message
            view.setNeedsLayout()
        }
    }
}

extension UIViewController {
    public func presentLoadingView(message: String? = nil) {
        if let viewController = presentedViewController as? LoadingViewController {
            viewController.message = message
        } else {
            let viewController = LoadingViewController()
            viewController.message = message
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = .crossDissolve
            present(viewController, animated: true, completion: nil)
        }
    }
    
    public func dismissLoadingView() {
        if let _ = presentedViewController as? LoadingViewController {
            dismiss(animated: true, completion: nil)
        }
    }
}
