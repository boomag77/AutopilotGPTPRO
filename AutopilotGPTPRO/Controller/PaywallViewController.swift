
import UIKit
import StoreKit

class PaywallViewController: UIViewController {
    
    //var subscriptionManager = SubscriptionManager.shared
    
    private let termsOfUseURL: String = "https://www.leoteor.com/app-s-legal-gpt-autopilot-user-agreement/"
    private let privacyPolicyURL: String = "https://www.leoteor.com/app-s-legal-gpt-autopilot-privacy-policy/"
    
    var products: [Product] = [] {
        didSet {
            tableView.reloadData()
            DispatchQueue.main.async { [weak self] in
                self?.updateTableViewHeight()
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGray6
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subscribe Now"
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
        config.baseBackgroundColor = UIColor.systemBlue
        config.baseForegroundColor = UIColor.white.withAlphaComponent(0.85)
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
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
        config.baseBackgroundColor = .systemBackground
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
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
        config.attributedTitle = AttributedString("Terms of Use", 
                                                  attributes: AttributeContainer(attributes))
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
        config.attributedTitle = AttributedString("Privacy policy", 
                                                  attributes: AttributeContainer(attributes))
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
        //view.alignment = .center
        
        view.addArrangedSubview(termsOfUseButton)
        view.addArrangedSubview(privacyPolicyButton)
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: "SubscriptionCell")
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 // Provide a reasonable estimate

        setupUI()
        
        DispatchQueue.main.async { [weak self] in
            self?.products = SubscriptionManager.shared.products
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        updateTableViewHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if size.height != preferredContentSize.height {
            preferredContentSize = size  // Dynamically adjust the size of the modal
        }
        
        preferredContentSize.height = 400
    }
    
    
    
    private func buyButtonTapped() {
        
        guard let product = products.first else {
            return
        }
        SubscriptionManager.shared.purchase(product) { [weak self] result in
            switch result {
                case .success(_):
                    self?.dismiss(animated: true)
                case .failure(_):
                    print("Failed complete purchase")
                    self?.dismiss(animated: true)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(buyButton)
        view.addSubview(docsButtonsStack)

        NSLayoutConstraint.activate([
                logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
                logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                logoImageView.heightAnchor.constraint(equalToConstant: 150),
                logoImageView.widthAnchor.constraint(equalToConstant: 150),
                
                titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                
                
                
                buyButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 30),
                buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                //buyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                
                docsButtonsStack.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 20),
                docsButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                docsButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                docsButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
                
                
            ])
    }
    
    private func updateTableViewHeight() {
        guard tableView.window != nil else {
            // TableView has not been added to the window, defer updating heights
            return
        }

        tableView.reloadData()
        tableView.layoutIfNeeded()
        let height = tableView.contentSize.height
        tableView.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.layoutIfNeeded()
    }
    
    private func openLink(stringURL: String) {
        
        if let url = URL(string: stringURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Handle the error if the URL couldn't be opened
                print("Cannot open URL")
                self.handleError(title: "Error", description: "Cannot open URL with GPT Autopilot for Interview \(stringURL)")
            }
        }
    }
    
    
    private func restorePurchasesButtonAction() -> UIAction {
        let action = UIAction { _ in
            Task {
                await SubscriptionManager.shared.restorePurchases()
            }
        }
        return action
    }
}

extension PaywallViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionTableViewCell
        
        let product = products[indexPath.row]
        
        cell.title = product.displayName
        cell.price = product.displayPrice
        
        
        
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

