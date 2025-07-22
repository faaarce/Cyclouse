//
//  AddressViewCell.swift
//  Cyclouse
//
//  Created by yoga arie on 07/11/24.
//

import UIKit

class AddressViewCell: UITableViewCell {
  
  private let containerView: UIView = {
        let object = UIView(frame: .zero)
        object.backgroundColor = ThemeColor.cardFillColor
        object.layer.cornerRadius = 12
        object.layer.borderWidth = 1
        object.layer.borderColor = UIColor.gray.cgColor
        return object
    }()

    private let iconAddressImage: UIImageView = {
        let object = UIImageView(image: .init(systemName: "mappin.and.ellipse"))
        object.contentMode = .scaleToFill
        object.layer.masksToBounds = true
        object.layer.cornerRadius = 12
        object.tintColor = ThemeColor.primary
        return object
    }()

    private let addressHeaderTitle: UILabel = {
        let label = LabelFactory.build(
            text: "Shipping Address",
            font: ThemeFont.semibold(ofSize: 12),
            textColor: ThemeColor.primary
        )
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let userData: UILabel = {
        let label = LabelFactory.build(
            text: "Faris",
            font: ThemeFont.semibold(ofSize: 12),
            textColor: .white
        )
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let addressDetail: UILabel = {
        let label = LabelFactory.build(
            text: "Jl. Boulevard Selatan, Blok C18 No.1 Marga Mulya, Kab Bekasi, Jawa Barat, ID 17510",
            font: ThemeFont.semibold(ofSize: 12),
            textColor: .white
        )
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var vAddressStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addressHeaderTitle, userData, addressDetail])
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

  
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
   
        setupView()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
      backgroundColor = .clear
      contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.addSubview(iconAddressImage)
        containerView.addSubview(vAddressStackView)
    }
  
  func updateAddress(_ newAddress: String) {
    addressDetail.text = newAddress
    setNeedsLayout()
    layoutIfNeeded()
  }

    private func layout() {
        containerView.snp.makeConstraints {
          $0.top.equalToSuperview().offset(8)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
          $0.bottom.equalToSuperview().offset(-8)
        }

        iconAddressImage.snp.makeConstraints { make in
            make.leading.equalTo(containerView).offset(12)
          make.top.equalTo(containerView.snp.top).offset(12)
          make.width.height.equalTo(20)
        }

        vAddressStackView.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(12)
            $0.leading.equalTo(iconAddressImage.snp.trailing).offset(8)
            $0.trailing.equalTo(containerView).offset(-12)
            $0.bottom.equalTo(containerView).offset(-12)
        }
    }
}

