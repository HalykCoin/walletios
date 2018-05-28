// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class AboutViewController: UIViewController {

    var viewModel = AboutViewModel()
    let account: Account
    let style = AboutViewStyle()

    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!

    var model = AboutViewModel() {
        didSet {
            imageView.image = viewModel.image
            titleLabel.text = viewModel.title
            subtitleLabel.text = viewModel.subtitle
        }
    }

    init(
        account: Account
        ) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.launch_screen_logo()
        view.addSubview(imageView)

        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
        titleLabel.text = NSLocalizedString("deposit.comingSoon.title", value: "Buy Halykcoins", comment: "")
        view.addSubview(titleLabel)

        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 3
        subtitleLabel.font = style.subtitleFont
        subtitleLabel.textColor = Colors.lightWhite
        subtitleLabel.text = NSLocalizedString("deposit.comingSoon.text", value: "Please visit https://halykcoin.org for information", comment: "")
        view.addSubview(subtitleLabel)

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            subtitleLabel,
            ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 240),
            ])

        configure(viewModel: viewModel)
    }

    func configure(viewModel: AboutViewModel) {
        title = viewModel.label
        view.backgroundColor = viewModel.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
