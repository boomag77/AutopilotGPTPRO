
import UIKit

class AnalyzeViewController: UIViewController {
    
    deinit {
        print("AnalyzeVC has been dismissed successfully.")
    }
    
    private var actIndicator: UIActivityIndicatorView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        actIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.actIndicator.stopAnimating()
            self?.actIndicator.isHidden = true
            
            // Add start button
            self?.setupStartButton()
            
        }
        
    }
    
    
    func setupUI() {
        
        view.backgroundColor = .black
        self.actIndicator = UIActivityIndicatorView.init(style: .medium)
        self.actIndicator.center = self.view.center
        actIndicator.color = .white
        self.view.addSubview(self.actIndicator)
        
        
        
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
