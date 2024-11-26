//
//  OrderPriceDetailCell.swift
//  Cyclouse
//
//  Created by yoga arie on 26/11/24.
//
import UIKit

class OrderPriceDetailCell: UITableViewCell {
    static let identifier = "OrderPriceDetailCell"
    
    // MARK: - UI Components
    private let orderDetail: UILabel = {
        LabelFactory.build(
            text: "Order Detail",
            font: ThemeFont.medium(ofSize: 14),
            textAlignment: .left
        )
    }()
    
    private let normalPriceLabel: UILabel = {
        LabelFactory.build(
            text: "Rp 5,000,000",
            font: ThemeFont.medium(ofSize: 12),
            textColor: ThemeColor.labelColorSecondary
        )
    }()
    
    private let normalPriceTitleLabel: UILabel = {
        LabelFactory.build(
            text: "Sub Total",
            font: ThemeFont.medium(ofSize: 12),
            textColor: ThemeColor.labelColorSecondary
        )
    }()
    
    private lazy var priceHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [normalPriceTitleLabel, normalPriceLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private let shippingTitleLabel: UILabel = {
        LabelFactory.build(
            text: "Shipping Cost",
            font: ThemeFont.medium(ofSize: 12),
            textColor: ThemeColor.labelColorSecondary
        )
    }()
    
    private let shippingPriceLabel: UILabel = {
        LabelFactory.build(
            text: "Rp 20,000",
            font: ThemeFont.medium(ofSize: 12),
            textColor: ThemeColor.labelColorSecondary
        )
    }()
    
    private lazy var shippingPriceHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [shippingTitleLabel, shippingPriceLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private let totalLabel: UILabel = {
        LabelFactory.build(
            text: "Total",
            font: ThemeFont.medium(ofSize: 12),
            textColor: ThemeColor.labelColorSecondary
        )
    }()
    
    private let totalPriceLabel: UILabel = {
        LabelFactory.build(
            text: "Rp 50,000",
            font: ThemeFont.medium(ofSize: 16),
            textColor: ThemeColor.primary
        )
    }()
    
    private lazy var totalHStackview: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalLabel, totalPriceLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.cardFillColor
        view.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return view
    }()
    
    private lazy var detailPriceVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            orderDetail,
            priceHStackView,
            shippingPriceHStackView,
            dividerView,
            totalHStackview
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        backgroundColor = .clear
        contentView.addSubview(detailPriceVStackView)
    }
    
    private func setupConstraints() {
        detailPriceVStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8))
        }
    }
    
    // MARK: - Configuration Method
    func configure(subtotal: Double, shippingCost: Double) {
        let total = subtotal + shippingCost
        
        normalPriceLabel.text = subtotal.toRupiah()
        shippingPriceLabel.text = shippingCost.toRupiah()
        totalPriceLabel.text = total.toRupiah()
    }
}
