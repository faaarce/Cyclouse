//
//  HistoryTableViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 23/09/24.
//

import SnapKit
import UIKit
import Kingfisher

class HistoryTableViewCell: UITableViewCell {

    private let itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private let totalPriceLabel: UILabel = {
        LabelFactory.build(text: "Rp 1.000.000", font: ThemeFont.semibold(ofSize: 12), textColor: .white)
    }()

    private let productCardView: UIView = {
        let object = UIView(frame: .zero)
        object.backgroundColor = ThemeColor.cardFillColor
        object.layer.cornerRadius = 10
        object.layer.masksToBounds = true
        return object
    }()

    private let quantityLabel: UILabel = {
        LabelFactory.build(text: "Total 1 Product", font: ThemeFont.semibold(ofSize: 12), textColor: ThemeColor.labelColorSecondary)
    }()

    private let dateLabel: UILabel = {
        LabelFactory.build(text: "", font: ThemeFont.regular(ofSize: 10), textColor: ThemeColor.labelColorSecondary)
    }()

    // Date formatters
    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        return formatter
    }()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        layout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dateLabel.text = ""
    }

    // MARK: - Helper Methods
    private func createItemView(image: String, name: String, price: Int, quantity: Int) -> UIView {
        let containerView = UIView()

        let productImage = UIImageView()
        productImage.contentMode = .scaleToFill
        productImage.kf.setImage(with: URL(string: image))

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.alignment = .leading
        vStack.distribution = .fillEqually

        let nameLabel = LabelFactory.build(
            text: name,
            font: ThemeFont.semibold(ofSize: 12),
            textColor: .white
        )

        let priceLabel = LabelFactory.build(
            text: price.toRupiah(),
            font: ThemeFont.semibold(ofSize: 12),
            textColor: .white
        )

        let quantityLabel = LabelFactory.build(
            text: "Qty: \(quantity)",
            font: ThemeFont.regular(ofSize: 10),
            textColor: ThemeColor.labelColorSecondary
        )

        [nameLabel, priceLabel, quantityLabel].forEach(vStack.addArrangedSubview)

        containerView.addSubview(productImage)
        containerView.addSubview(vStack)

        productImage.snp.makeConstraints {
            $0.width.equalTo(75)
            $0.height.equalTo(56)
            $0.left.equalToSuperview().offset(10)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        vStack.snp.makeConstraints {
            $0.top.equalTo(productImage.snp.top)
            $0.left.equalTo(productImage.snp.right).offset(12)
            $0.bottom.equalTo(productImage.snp.bottom)
        }

        return containerView
    }

    private func formatDate(_ dateString: String) -> String {
        guard let date = iso8601Formatter.date(from: dateString) else { return "" }
        return outputDateFormatter.string(from: date)
    }

    private func layout() {
        productCardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.left.right.equalToSuperview()
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }

        itemsStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
        }

        totalPriceLabel.snp.makeConstraints {
            $0.top.equalTo(itemsStackView.snp.bottom).offset(15)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }

        quantityLabel.snp.makeConstraints {
            $0.top.equalTo(itemsStackView.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(10)
        }
    }

    // MARK: - Configuration Methods
    func configure(with bikes: [BikeDatabase]) {
        // Clear existing items
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var totalPrice = 0
        var totalQuantity = 0

        // Add all bikes
        bikes.forEach { bike in
            let itemView = createItemView(
                image: bike.images.first ?? "",
                name: bike.name,
                price: bike.price,
                quantity: bike.cartQuantity
            )
            itemsStackView.addArrangedSubview(itemView)

            totalPrice += bike.price * bike.cartQuantity
            totalQuantity += bike.cartQuantity
        }

        // Update totals
        quantityLabel.text = "Total \(totalQuantity) Product\(totalQuantity > 1 ? "s" : "")"
        totalPriceLabel.text = totalPrice.toRupiah()
    }

    // For single bike configuration
    func configure(with bike: BikeDatabase) {
        configure(with: [bike])
    }
  
  func configureDetail(order: OrderItem) {
    itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    itemsStackView.addArrangedSubview(createItemView(image: order.image, name: order.name, price: order.price, quantity: order.quantity))
  }

    func configure(with orderHistory: OrderHistory) {
        // Clear existing items
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Format and set the date
        dateLabel.text = formatDate(orderHistory.createdAt)

        // Add all items from order history
        orderHistory.items.forEach { item in
            let itemView = createItemView(
                image: item.image,
                name: item.name,
                price: item.price,
                quantity: item.quantity
            )
            itemsStackView.addArrangedSubview(itemView)
        }

        // Update totals
        let totalItems = orderHistory.items.reduce(0) { $0 + $1.quantity }
        quantityLabel.text = "Total \(totalItems) Product\(totalItems > 1 ? "s" : "")"
        totalPriceLabel.text = orderHistory.total.toRupiah()
    }

    // Show loading placeholders when data is loading
    func showLoadingPlaceholder() {
        // Clear existing items
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Set placeholders for labels
        dateLabel.text = "Loading..."
        totalPriceLabel.text = "..."
        quantityLabel.text = "Total ... Products"

        // Add placeholder item views
        let placeholderView = createPlaceholderItemView()
        itemsStackView.addArrangedSubview(placeholderView)
    }

    // Create placeholder item view for loading state
    private func createPlaceholderItemView() -> UIView {
        let containerView = UIView()

        let productImage = UIImageView()
        productImage.contentMode = .scaleAspectFill
        productImage.image = UIImage(named: "placeholder_image") // Replace with your placeholder image

        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.alignment = .leading
        vStack.distribution = .fillEqually

        let nameLabel = UILabel()
        nameLabel.text = "Loading..."
        nameLabel.font = ThemeFont.semibold(ofSize: 12)
        nameLabel.textColor = .white

        let priceLabel = UILabel()
        priceLabel.text = "..."
        priceLabel.font = ThemeFont.semibold(ofSize: 12)
        priceLabel.textColor = .white

        let quantityLabel = UILabel()
        quantityLabel.text = "Qty: ..."
        quantityLabel.font = ThemeFont.regular(ofSize: 10)
        quantityLabel.textColor = ThemeColor.labelColorSecondary

        [nameLabel, priceLabel, quantityLabel].forEach(vStack.addArrangedSubview)

        containerView.addSubview(productImage)
        containerView.addSubview(vStack)

        productImage.snp.makeConstraints {
            $0.width.equalTo(75)
            $0.height.equalTo(56)
            $0.left.equalToSuperview().offset(10)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        vStack.snp.makeConstraints {
            $0.top.equalTo(productImage.snp.top)
            $0.left.equalTo(productImage.snp.right).offset(12)
            $0.bottom.equalTo(productImage.snp.bottom)
        }

        return containerView
    }

    private func setupViews() {
        contentView.addSubview(productCardView)
        [dateLabel, itemsStackView, totalPriceLabel, quantityLabel].forEach(productCardView.addSubview)
    }
}
