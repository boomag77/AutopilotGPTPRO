
import UIKit

class AnalyzeViewController: UIViewController {
    
    deinit {
        print("AnalyzeVC has been dismissed successfully.")
    }
    
    //private var actIndicator: UIActivityIndicatorView!
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: .medium)
        indicator.color = .label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.title = "Start"
        config.baseBackgroundColor = UIColor.systemBlue
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        config.cornerStyle = .large
        button.configuration = config
        
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(startButtonTapped(), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Analyzing received data"
        label.textColor = .label
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            
            // Add start button
            //self?.setupStartButton()
            let tabBarController = TabBarController()
            let paywallViewController = PaywallViewController()
            tabBarController.modalPresentationStyle = .fullScreen
            self?.present(tabBarController, animated: true) { [unowned tabBarController] in
                tabBarController.present(paywallViewController, animated: false)
            }
            
        }
        
    }
    
    
    func setupUI() {
        
        view.backgroundColor = .systemBackground
        
//        self.activityIndicator = UIActivityIndicatorView.init(style: .medium)
//        self.activityIndicator.center = self.view.center
        //actIndicator.color = .label
        view.addSubview(activityIndicator)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        
    }
    
    private func setupStartButton() {
        view.addSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.layoutIfNeeded()
    }
    
    private func startButtonTapped() -> UIAction {
        let action = UIAction { _ in
            let tabBarController = TabBarController()
            tabBarController.modalPresentationStyle = .fullScreen
            self.present(tabBarController, animated: true)
        }
        return action
    }

}
