
import UIKit

class IntroductionViewController: UIViewController {
    
    private var model = IntroductionViewModel()
    
    private var nextButtonTracked: Bool = false
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "InterviewAI-Buddy"
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = model.totalScreensCount
        pageControl.currentPage = model.currentScreenNumber
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = AppConstants.Color.bloombergBlue
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = OnboardingButton()
        button.title = "Next"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.nextButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private var viewModel = IntroductionViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        if let content = model.getScreenContent() {
            configureContentView(content)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeManager.shared.track(eventType: "Onboarding-Page1-Showed")
    }
    
    private func configure() {
        
        setupBackgroundImageView()
        
        view.addSubview(nextButton)
        view.addSubview(pageControl)
        view.addSubview(appNameLabel)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),
            
            appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            titleLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 30),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: pageControl.topAnchor, constant: -10)
        ])
    }
    
    private func setupBackgroundImageView() {
        
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.sendSubviewToBack(backgroundImageView)
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 79/255.0, alpha: 0.46)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureContentView(_ content: ScreenContent) {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.pageControl.currentPage = content.screenNumber
            self.backgroundImageView.image = UIImage(named: content.imageName())
            
            self.titleLabel.text = content.title
            self.descriptionLabel.text = content.description
            
            self.view.layoutIfNeeded()
        })
        
        
        
    }
    
    private func nextButtonTapped() {
        
        //track button "Next" only one time at First screen
        if !self.nextButtonTracked {
            AmplitudeManager.shared.track(eventType: "Onboading-Button_Next-Pressed")
            self.nextButtonTracked = true
        }
        
        if let content = model.getScreenContent() {
            configureContentView(content)
        } else {
            showQuestions()
        }
    }
    
    private func showQuestions() {
        
        //For testing
        
//        let vc = AnalyzeViewController()
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true)
        
        let questionsVC = QuestionsViewController()
        questionsVC.modalPresentationStyle = .fullScreen
        self.present(questionsVC, animated: true)
    }
    
}
