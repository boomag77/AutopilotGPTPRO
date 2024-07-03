

import UIKit
//import SpriteKit

class QuestionsViewController: UIViewController {
    
    let viewModel = QuestionsViewModel(lang: .english)
    
    private var continueButtonTracked: Bool = false
    
    private var questionIndex: Int = 0
    private var currentQuestion: Question?
    private var animationTriggered = false
    private var answerSelected: Bool = false
    private var markers: [UIView] = []
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .label
        //label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
        label.text = currentQuestion?.title
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        //tableView.backgroundColor = .systemBackground
        if traitCollection.userInterfaceStyle == .light {
            // Light mode
            tableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 242/255, alpha: 1.0)
        } else {
            // Dark mode or unspecified
            tableView.backgroundColor = UIColor.systemGray6
        }
        tableView.separatorStyle = .none
        tableView.setContentHuggingPriority(.required, for: .vertical)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var answersView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemCyan
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var onboardingButton: UIButton = {
        let button = OnboardingButton()
        button.title = "Continue"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.continueButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var progressBar: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        
        view.tintColor = AppConstants.Color.bloombergBlue
        view.trackTintColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OnboardingTableViewCell.self, forCellReuseIdentifier: "AnswerCell")
            
        configureQuestionsView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeManager.shared.track(eventType: "Onboarding-Question1-Showed")
        showQuestion()
        
    }
    
    
    private func configureQuestionsView() {
        
        //view.backgroundColor = .systemBackground
        
        if traitCollection.userInterfaceStyle == .light {
            // Light mode
            view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 242/255, alpha: 1.0)
        } else {
            // Dark mode or unspecified
            view.backgroundColor = UIColor.systemGray6
        }

        
        view.addSubview(progressBar)
        view.addSubview(questionLabel)
        view.addSubview(onboardingButton)
        view.addSubview(tableView)
        //answersView.addSubview(tableView)
        updateConstraints()
    }
    
    private func updateConstraints() {
        
        let padding: CGFloat = 30
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 39),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -39),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            
            questionLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 30),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            tableView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(greaterThanOrEqualTo: onboardingButton.topAnchor, constant: -padding)
        ])
        setupMilestonesMarkers()
    }
    
    private func setupMilestonesMarkers() {
        view.layoutIfNeeded()
        let progressWidth: CGFloat = progressBar.frame.width
        let spacing = progressWidth / CGFloat(AppConstants.milestonesCount - 1)
        
        for i in 0..<AppConstants.milestonesCount {
            let marker = UIView()
            //marker.backgroundColor = i == 0 ? AppConstants.Color.bloombergBlue : .systemGray4
            marker.backgroundColor = .systemGray4
            marker.layer.cornerRadius = AppConstants.milestoneMarkerDiameter / 2
            marker.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(marker)
            
            NSLayoutConstraint.activate([
                marker.centerXAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: CGFloat(i) * CGFloat(spacing)),
                marker.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
                marker.widthAnchor.constraint(equalToConstant: AppConstants.milestoneMarkerDiameter),
                marker.heightAnchor.constraint(equalToConstant: AppConstants.milestoneMarkerDiameter)
            ])
            
            markers.append(marker)
        }
    }
    
    private func continueButtonTapped() {
        guard self.answerSelected else {
            return
        }
        if !self.continueButtonTracked {
            AmplitudeManager.shared.track(eventType: "Onboading-Question1-Button_Continue-Pressed")
            self.continueButtonTracked = true
        }
        showQuestion()
    }
    
    private func showQuestion() {
        
        guard let nextQuestion = viewModel.getQuestion() else {
            self.progressBar.setProgress(1.0, animated: true)
            self.updateProgress(to: 1, of: 1)
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "completedOnboarding")
            self.showAnalyzeVC()
//            let alert = UIAlertController(title: "Message", message: "That's it!", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
//                let defaults = UserDefaults.standard
//                defaults.set(true, forKey: "completedOnboarding")
//                self?.showAnalyzeVC()
//            }
//            let resetAction = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
//                let defaults = UserDefaults.standard
//                defaults.set(false, forKey: "completedOnboarding")
//                self?.viewModel.resetQuestionIndex()
//
//            }
//            alert.addAction(okAction)
//            alert.addAction(resetAction)
//            self.present(alert, animated: true, completion: nil)
            return
        }
        self.currentQuestion = nextQuestion
        Task {
            self.questionLabel.text = currentQuestion?.title
            view.layoutIfNeeded()
            tableView.reloadData()
            animateTableViewCells()
        }
        self.answerSelected = false
    }
    
    private func showAnalyzeVC() {
        let analyzeVC = AnalyzeViewController()
        analyzeVC.modalPresentationStyle = .fullScreen
        self.present(analyzeVC, animated: true)
        //self.dismiss(animated: false)
    }
    
    
    private func animateTableViewCells() {
        
        let cells = tableView.visibleCells
        let tableViewWidth = tableView.bounds.width
        
        for (index, cell) in cells.enumerated() {
            (cell as! OnboardingTableViewCell).checked = false
            cell.transform = CGAffineTransform(translationX: tableViewWidth, y: 0)
            
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.1, options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
        }
        
    }
    
    
}

extension QuestionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestion?.answers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell",
                                                 for: indexPath) as! OnboardingTableViewCell
        
        cell.title = self.currentQuestion?.answers[indexPath.row]
        
        return cell
    }
}

extension QuestionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.answerSelected = true
        
        let cells = tableView.visibleCells
        for (index, cell) in cells.enumerated() {
            let currCell = cell as! OnboardingTableViewCell
            if indexPath.row == index {
                currCell.checked = true
                
            } else {
                if currCell.checked {
                    currCell.checked.toggle()
                }
            }
            
        }
        
    }
}

extension QuestionsViewController: OnboardingViewModelDelegate {
    
    func resetProgress() {
        progressBar.setProgress(0, animated: false)
    }
    
    
    func updateProgress(to step: Int, of steps: Int) {
        guard steps > 0 else { return }
        
        let stepSize = 1.00 / Float(steps)
        //print("Step size: \(stepSize)")
        let newProgress = self.progressBar.progress + stepSize
        //print("Progress: \(newProgress)")
        
        Task { [weak self] in
            
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                self.progressBar.setProgress(newProgress, animated: true)
                
                // Update markers
                let progressX = self.progressBar.frame.origin.x + self.progressBar.frame.width * CGFloat(newProgress)
                
                for marker in self.markers {
                    if progressX >= marker.frame.origin.x {
                        marker.backgroundColor = AppConstants.Color.bloombergBlue
                    } else {
                        marker.backgroundColor = .systemGray4
                    }
                }
            }
            
//            while self.progressBar.progress < newProgress {
//                try await Task.sleep(nanoseconds: 100_000_000) // delay (100ms)
//                
//                // Update progress bar
//                //let currentProgress: Float = (self.progressBar.progress) + stepSize
//                
//                self.progressBar.setProgress(newProgress, animated: true)
//                
//                // Update markers
//                let progressX = self.progressBar.frame.origin.x + progressBar.frame.width * CGFloat(newProgress)
//                
//                for marker in self.markers {
//                    if progressX >= marker.frame.origin.x {
//                        marker.backgroundColor = AppConstants.Color.bloombergBlue
//                    } else {
//                        marker.backgroundColor = .systemGray4
//                    }
//                }
//            }
        }
    }
}
