
import UIKit
import Adapty

class PaywallViewController: UIViewController {
    
    var products: [AdaptyProduct] = []
    weak var adaptyManager: AdaptyManager?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subscribe Now"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProducts()
        tableView.dataSource = self
        tableView.reloadData()
        setupUI()
    }
    
    private func setupProducts() {
        guard let manager = adaptyManager, let products = manager.products else {
            self.products = []
            return
        }
        self.products = products
    }
    
    private func buyButtonTapped() {
        guard let product = products.first else {
            return
        }
        adaptyManager?.makePurchase(product: product , from: self)
    }
    
//    private func loadProducts() {
//        self.products = AdaptyManager.shared.products
//    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.setContentHuggingPriority(.required, for: .vertical)
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(buyButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buyButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            buyButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            buyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buyButton.topAnchor, constant: -10)
            
            
        ])
    }

}

extension PaywallViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let product = products[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = product.localizedTitle
        content.secondaryText = product.localizedDescription
        content.secondaryTextProperties.color = .gray
        cell.contentConfiguration = content
        
        
        
        return cell
    }
}

