// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class BalanceTitleView: UIView {

    let titleLabel = UILabel()
    let subTitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .right

        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.textAlignment = .right

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subTitleLabel,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func configure(viewModel: BalanceBaseViewModel) {
        titleLabel.attributedText = viewModel.attributedCurrencyAmount
        subTitleLabel.attributedText = viewModel.attributedAmount
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
