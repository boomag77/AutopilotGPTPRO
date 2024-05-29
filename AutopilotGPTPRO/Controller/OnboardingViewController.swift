

import UIKit
import SpriteKit

class OnboardingViewController: UIViewController {
    
    let viewModel = OnboardingViewModel(lang: .english)
    
    private var questionIndex: Int = 0
    private var currentQuestion: Question?
    private var animationTriggered = false
    private var answerSelected: Bool = false
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.text = currentQuestion?.title
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
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
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "Continue"
        config.baseBackgroundColor = AppConstants.Color.bloombergBlue
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        config.cornerStyle = .large
        button.configuration = config
        
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.continueButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var progressBar: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.tintColor = AppConstants.Color.bloombergBlue
        view.trackTintColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OnboardingTableViewCell.self, forCellReuseIdentifier: "AnswerCell")
            
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setTableViewInsets()
        //print("Total height of visible cells: \(totalHeight)")
//        if !animationTriggered {
//            animateTableViewCells()
//            animationTriggered = true
//        }
        //animateTableViewCells()
        showQuestion()
    }
    
//    private func setTableViewInsets() {
//        var totalHeight: CGFloat = 0
//        for cell in tableView.visibleCells {
//            totalHeight += cell.bounds.height
//        }
//        let remainigSpace = tableView.bounds.height - totalHeight
//        let verticalInset = max(0, remainigSpace/2)
//        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//    }
    
    
    private func setup() {
        view.backgroundColor = .systemBackground
        view.addSubview(progressBar)
        view.addSubview(questionLabel)
        view.addSubview(continueButton)
        view.addSubview(tableView)
        //answersView.addSubview(tableView)
        updateConstraints()
    }
    
    private func updateConstraints() {
        
        let padding: CGFloat = 30
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            
            questionLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            
            tableView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(greaterThanOrEqualTo: continueButton.topAnchor, constant: -padding)
        ])
    }
    
    private func continueButtonTapped() {
        guard self.answerSelected else {
            return
        }
        showQuestion()
    }
    
    private func showQuestion() {
        
        guard let nextQuestion = viewModel.getQuestion() else {
            self.progressBar.setProgress(1.0, animated: true)
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

extension OnboardingViewController: UITableViewDataSource {
    
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

extension OnboardingViewController: UITableViewDelegate {
    
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

extension OnboardingViewController: OnboardingViewModelDelegate {
    
    func resetProgress() {
        progressBar.setProgress(0, animated: false)
    }
    
    
    func updateProgress(to step: Int, of steps: Int) {
        
        let stepSize = 1.0 / Float(steps-1)
        let progress = Float(step) * stepSize
        
        Task { [weak self] in
            //let currentProgress = self?.progressBar.progress ?? 0
            while self?.progressBar.progress ?? 0 < progress {
                try await Task.sleep(nanoseconds: 100_000_000) // Simulate delay (100ms)
                self?.progressBar.setProgress((self?.progressBar.progress ?? 0) + 0.01, animated: true)
            }
        }
    }
}
