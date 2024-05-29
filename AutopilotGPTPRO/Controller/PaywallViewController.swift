import UIKit
import StoreKit
import Adapty

class PaywallViewController: UIViewController {

    weak var parentController: UIViewController!
    
    private var timer: Timer?
    private let imageNames = ["pw_image2", "pw_image3", "pw_image5", "pw_image6"]
    private var currentImageIndex = 0
    
    private let termsOfUseURL: String = AppConstants.Links.termsOfUseURL
    private let privacyPolicyURL: String = AppConstants.Links.privacyPolicyURL
    
    var products: [AdaptyPaywallProduct] = [] {
        didSet {
            // Defer UI updates to when the view is added to the window
            DispatchQueue.main.async { [weak self] in
                self?.updateUI()
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.isUserInteractionEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pw_image2")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemGray6.cgColor
        ]
        gradientLayer.locations = [0, 0.8]
        return gradientLayer
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Master Your interview, Master Your Life"
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = boldTitleFont()
        label.textColor = .label.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "and get full access"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .label.withAlphaComponent(0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buyButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "Subscribe"
        config.baseBackgroundColor = AppConstants.Color.bloombergBlue
        config.baseForegroundColor = UIColor.white
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        config.cornerStyle = .large
        button.configuration = config
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.clipsToBounds = true
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.buyButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var closeButon: RoundButton = {
        let button = RoundButton()
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark")
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        config.baseBackgroundColor = .systemBackground.withAlphaComponent(0.3)
        config.baseForegroundColor = .label.withAlphaComponent(0.85)
        button.configuration = config
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var termsOfUseButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label.withAlphaComponent(0.85)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ]
        config.attributedTitle = AttributedString("Terms of Use", attributes: AttributeContainer(attributes))
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [unowned self] _ in
            self.openLink(stringURL: self.termsOfUseURL)
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label.withAlphaComponent(0.85)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ]
        config.attributedTitle = AttributedString("Privacy policy", attributes: AttributeContainer(attributes))
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [unowned self] _ in
            self.openLink(stringURL: self.privacyPolicyURL)
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var docsButtonsStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.setContentHuggingPriority(.required, for: .vertical)
        view.addArrangedSubview(termsOfUseButton)
        view.addArrangedSubview(privacyPolicyButton)
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var restorePurchasesButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.title = "Restore Purchases"
        config.baseForegroundColor = .label.withAlphaComponent(0.85)
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(restorePurchasesButtonAction(), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: "SubscriptionCell")
        tableView.dataSource = self
        
        self.products = PurchasesObserver.shared.products!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableViewHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = imageView.bounds
        if gradientLayer.superlayer == nil {
            imageView.layer.addSublayer(gradientLayer)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSlideShow()
    }
    
    private func startSlideShow() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(showNextImageWithFade), userInfo: nil, repeats: true)
    }
    
    private func stopSlideShow() {
        timer?.invalidate()
    }
    
    @objc private func showNextImageWithFade() {
        currentImageIndex = (currentImageIndex + 1) % imageNames.count
        let nextImage = UIImage(named: imageNames[currentImageIndex])
        
        UIView.transition(with: imageView,
                          duration: 1.0,
                          options: .transitionCrossDissolve,
                          animations: {
                                self.imageView.image = nextImage
                            },
                          completion: nil
        )
    }
    
    private func buyButtonTapped() {
        guard let product = products.first else {
            return
        }
        
        PurchasesObserver.shared.makePurchase(product) { [weak self] result in
            switch result {
                case .success(let profile):
                    if let isActive = profile.subscriptions[AppConstants.monthlySubscriptonId]?.isActive, isActive {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        
        view.addSubview(imageView)
        view.addSubview(docsButtonsStack)
        view.addSubview(restorePurchasesButton)
        view.addSubview(buyButton)
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            docsButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            docsButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            docsButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            restorePurchasesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            restorePurchasesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            restorePurchasesButton.bottomAnchor.constraint(equalTo: docsButtonsStack.topAnchor, constant: -10),
            
            buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            buyButton.bottomAnchor.constraint(equalTo: restorePurchasesButton.topAnchor, constant: -10),
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            //imageView.bottomAnchor.constraint(equalTo: buyButton.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            tableView.bottomAnchor.constraint(equalTo: buyButton.topAnchor, constant: -30)
        ])
        setupTitleView()
        setupCloseButton()
    }
    
    private func setupTitleView() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -30)
        ])
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            //imageView.heightAnchor.constraint(equalToConstant: 200) // Example height constraint
        ])
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButon)
        NSLayoutConstraint.activate([
            closeButon.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButon.heightAnchor.constraint(equalToConstant: 40),
            closeButon.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10)
        ])
    }
    
    private func boldTitleFont() -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        if let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: boldFontDescriptor, size: 0)
        } else {
            return UIFont.preferredFont(forTextStyle: .title1)
        }
    }
    
    private func updateTableViewHeight() {
        guard tableView.window != nil else {
            return
        }

        tableView.reloadData()
        tableView.layoutIfNeeded()
        
        var totalHeight: CGFloat = 0.0
        for cell in tableView.visibleCells {
            totalHeight += cell.frame.height
        }
        
        tableView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        view.layoutIfNeeded()
    }
    
    private func openLink(stringURL: String) {
        if let url = URL(string: stringURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL")
                self.handleError(title: "Error", description: "Cannot open URL with Interview AI-Buddy \(stringURL)")
            }
        }
    }
    
    private func restorePurchasesButtonAction() -> UIAction {
        let action = UIAction { _ in
            Task {
                PurchasesObserver.shared.restore() { [weak self] error in
                    if let error = error {
                        print(error.description)
                    } else {
                        self?.dismiss(animated: true)
                    }
                }
            }
        }
        return action
    }
    
    private func updateUI() {
        tableView.reloadData()
        setupUI()
        startSlideShow()
        if let price = products.first?.localizedPrice {
            buyButton.configuration?.title = "Subscribe for \(price)/month"
        }
        view.layoutIfNeeded()
        updateTableViewHeight()
    }
}

extension PaywallViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionTableViewCell
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        let product = products[indexPath.row]
        cell.title = product.paywallName
        cell.price = product.localizedPrice
        return cell
    }
}

extension PaywallViewController {
    
    private func handleError(title: String, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
