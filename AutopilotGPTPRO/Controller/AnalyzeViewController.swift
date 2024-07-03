
import UIKit

class AnalyzeViewController: UIViewController {
    
    private var stepViews: [StepView] = [
        StepView(text: "Analyzing received data", isCompleted: false),
        StepView(text: "Searching for a perfect plan", isCompleted: false),
        StepView(text: "Counting the number of sessions", isCompleted: false),
        StepView(text: "Calculating program", isCompleted: false)
    ]
    
    private var links: [DottedLineView?] = [nil]
    
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
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "How can AI-Buddy improve your life?"
        let fontSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        //label.adjustsFontForContentSizeCategory = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bg_anlz")
        imageView.contentMode = .scaleAspectFill
        //imageView.clipsToBounds = true
        imageView.layer.contentsGravity = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.locations = [0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = imageView.bounds
        
        imageView.layer.addSublayer(gradientLayer)
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private lazy var progressView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .clear
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fillEqually
        //view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        startCompletionProgress() { 
            
            Task {
                let tabBarController = TabBarController()
                let paywallViewController = PaywallViewController()
                paywallViewController.callSource = .onboarding
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: false) { [unowned tabBarController] in
                    tabBarController.present(paywallViewController, animated: true)
                }
            }
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gradientLayer = backgroundImageView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundImageView.bounds
        }
    }
    
    private func startCompletionProgress(completion: @escaping () -> Void) {
        
        Task { [unowned self] in
            for (index, stepView) in self.stepViews.enumerated() {
                stepView.startProcessing()
                try await Task.sleep(nanoseconds: 1_000_000_000)
                stepView.setCompleted()
                if let link = self.links[index] {
                    link.setCompleted()
                }
            }
            completion()
        }
        
        
    }
    
    
    func configure() {
        
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 30)
        ])
        view.sendSubviewToBack(backgroundImageView)
        
        //view.addSubview(activityIndicator)
        view.addSubview(label)
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            //activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            progressView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        setupProgressView()
    }
    
    private func setupProgressView() {
        
        for i in 0..<stepViews.count {
            progressView.addArrangedSubview(stepViews[i])
            if i == stepViews.count-1 { break }
            
            let dottedLine = DottedLineView()
            dottedLine.translatesAutoresizingMaskIntoConstraints = false
            
            
            
            progressView.addArrangedSubview(dottedLine)
            
            
            NSLayoutConstraint.activate([
                //dottedLine.heightAnchor.constraint(equalTo: progressView.heightAnchor),
                dottedLine.centerXAnchor.constraint(equalTo: stepViews[i].circleView.centerXAnchor)
            ])
            
            self.links.append(dottedLine)
        }
    }

}
