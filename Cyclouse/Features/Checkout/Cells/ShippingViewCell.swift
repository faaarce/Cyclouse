//
//  ShippingViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 20/06/25.
//

import UIKit
import SnapKit

protocol ShippingViewCellDelegate: AnyObject {
    func didSelectShipping(_ shipping: ShippingSelect)
}

class ShippingViewCell: UITableViewCell {
    
    weak var delegate: ShippingViewCellDelegate?
    
    private let shippingTitle: UILabel = {
        LabelFactory.build(
            text: "Shipping Type",
            font: ThemeFont.medium(ofSize: 16),
            textColor: .white
        )
    }()
    
    private var shippingCategory: [ShippingSelect] = [
        ShippingSelect(name: "Regular", isSelected: true, price: "Rp 25.000", estimatedTime: "Estimated 3-5 working days"),
        ShippingSelect(name: "Express", isSelected: false, price: "Rp 45.000", estimatedTime: "Estimated 1-2 working days"),
        ShippingSelect(name: "Same Day", isSelected: false, price: "Rp 75.000", estimatedTime: "Delivered today")
    ]
    
    private var shippingOptionViews: [ShippingOptionView] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        layout()
        createShippingOptions()
        // Select first option by default
        if let firstShipping = shippingCategory.first {
            delegate?.didSelectShipping(firstShipping)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset selection states to prevent rendering issues
        shippingOptionViews.forEach { $0.setSelected(false, animated: false) }
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(shippingTitle)
    }
    
    private func layout() {
        shippingTitle.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
    }
    
    private func createShippingOptions() {
        var previousView: UIView? = shippingTitle
        
        shippingCategory.enumerated().forEach { index, shipping in
            let optionView = ShippingOptionView()
            optionView.configure(with: shipping)
            optionView.tag = index
            
            // Add tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shippingOptionTapped(_:)))
            optionView.addGestureRecognizer(tapGesture)
            
            contentView.addSubview(optionView)
            shippingOptionViews.append(optionView)
            
            optionView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(80)
                
                if let previous = previousView {
                    make.top.equalTo(previous.snp.bottom).offset(previousView == shippingTitle ? 20 : 12)
                } else {
                    make.top.equalTo(shippingTitle.snp.bottom).offset(20)
                }
                
                if index == shippingCategory.count - 1 {
                    make.bottom.equalToSuperview().offset(-20)
                }
            }
            
            previousView = optionView
        }
        
        // Update initial selection state
        updateSelectionStates(animated: false)
    }
    
    @objc private func shippingOptionTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        let selectedIndex = tappedView.tag
        
        // Update model
        shippingCategory = shippingCategory.enumerated().map { index, shipping in
            var updatedShipping = shipping
            updatedShipping.isSelected = index == selectedIndex
            return updatedShipping
        }
        
        // Notify delegate
        if shippingCategory.indices.contains(selectedIndex) {
            let selectedShipping = shippingCategory[selectedIndex]
            delegate?.didSelectShipping(selectedShipping)
        }
        
        // Update UI
        updateSelectionStates(animated: true)
    }
    
    private func updateSelectionStates(animated: Bool) {
        shippingOptionViews.enumerated().forEach { index, view in
            let isSelected = shippingCategory[index].isSelected
            view.setSelected(isSelected, animated: animated)
        }
    }
}

// MARK: - ShippingOptionView
private class ShippingOptionView: UIView {
    
    private let containerView = UIView()
    private let radioButton = UIView()
    private let innerCircle = UIView()
    private let nameLabel = UILabel()
    private let estimatedLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Container setup
        containerView.backgroundColor = ThemeColor.cardFillColor
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.clipsToBounds = true
        addSubview(containerView)
        
        // Radio button setup
        radioButton.layer.cornerRadius = 12
        radioButton.layer.borderWidth = 2
        radioButton.layer.borderColor = UIColor(white: 0.3, alpha: 1.0).cgColor
        radioButton.backgroundColor = .clear
        containerView.addSubview(radioButton)
        
        // Inner circle setup
        innerCircle.layer.cornerRadius = 6
        innerCircle.backgroundColor = ThemeColor.primary
        innerCircle.alpha = 0
        innerCircle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        radioButton.addSubview(innerCircle)
        
        // Labels setup
        nameLabel.font = ThemeFont.semibold(ofSize: 16)
        nameLabel.textColor = .white
        containerView.addSubview(nameLabel)
        
        estimatedLabel.font = ThemeFont.regular(ofSize: 14)
        estimatedLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        containerView.addSubview(estimatedLabel)
        
        priceLabel.font = ThemeFont.semibold(ofSize: 16)
        priceLabel.textColor = ThemeColor.primary
        priceLabel.textAlignment = .right
        containerView.addSubview(priceLabel)
    }
    
    private func layout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        radioButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        innerCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(radioButton.snp.right).offset(16)
            make.top.equalToSuperview().offset(20)
            make.right.lessThanOrEqualTo(priceLabel.snp.left).offset(-10)
        }
        
        estimatedLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-20)
            make.right.lessThanOrEqualTo(priceLabel.snp.left).offset(-10)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(100)
        }
    }
    
    func configure(with shipping: ShippingSelect) {
        nameLabel.text = shipping.name
        estimatedLabel.text = shipping.estimatedTime
        priceLabel.text = shipping.price
        setSelected(shipping.isSelected, animated: false)
    }
    
    func setSelected(_ selected: Bool, animated: Bool) {
        // Cancel any pending animations
        self.layer.removeAllAnimations()
        self.containerView.layer.removeAllAnimations()
        self.radioButton.layer.removeAllAnimations()
        self.innerCircle.layer.removeAllAnimations()
        
        let duration = animated ? 0.3 : 0
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            // Update container
            self.containerView.layer.borderColor = selected ?
                ThemeColor.primary.cgColor : UIColor.clear.cgColor
            self.containerView.backgroundColor = selected ?
                ThemeColor.cardFillColor.withAlphaComponent(0.9) :
                ThemeColor.cardFillColor
            
            // Update radio button
            self.radioButton.layer.borderColor = selected ?
                ThemeColor.primary.cgColor :
                UIColor(white: 0.3, alpha: 1.0).cgColor
            
            // Update inner circle
            self.innerCircle.alpha = selected ? 1.0 : 0
            self.innerCircle.transform = selected ?
                CGAffineTransform.identity :
                CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: nil)
    }
}
