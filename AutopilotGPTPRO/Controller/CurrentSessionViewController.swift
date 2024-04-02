
import UIKit

class CurrentSessionViewController: UIViewController {
    
    private var recording: Bool = false {
        didSet {
            inactiveBottomView.isHidden.toggle()
            activeBottomView.isHidden.toggle()
        }
    }
    
    private var tokens: Int = 896
    
    private lazy var recButton: UIButton = {
        let button = SessionControlsButton()
        
        var config = UIButton.Configuration.filled()
        config.title = "REC"
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        button.configuration = config
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.recButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = SessionControlsButton()
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "checkmark")
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        button.configuration = config
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = SessionControlsButton()
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark")
        config.baseBackgroundColor = .systemRed
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        button.configuration = config
        button.clipsToBounds = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var inactiveBottomView: UIView = {
        let view = UIView()
        view.isHidden = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activeBottomView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messagesView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.endSession()
    }
    
    private func setup() {
        view.backgroundColor = .black
        
        self.view.addSubview(messagesView)
        self.view.addSubview(inactiveBottomView)
        self.view.insertSubview(activeBottomView, at: 0)
        
        NSLayoutConstraint.activate([
            inactiveBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inactiveBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inactiveBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inactiveBottomView.heightAnchor.constraint(equalToConstant: 84),
            
            activeBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            activeBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            activeBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            activeBottomView.heightAnchor.constraint(equalToConstant: 84),
            
            messagesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            messagesView.bottomAnchor.constraint(equalTo: inactiveBottomView.topAnchor)
        ])
        
        setupBottomViews()
    }
    
    private func setupBottomViews() {
        
        inactiveBottomView.addSubview(recButton)
        
        NSLayoutConstraint.activate([
            recButton.centerXAnchor.constraint(equalTo: inactiveBottomView.centerXAnchor),
            recButton.bottomAnchor.constraint(equalTo: inactiveBottomView.bottomAnchor),
            recButton.heightAnchor.constraint(equalToConstant: 64),
            recButton.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        activeBottomView.addSubview(sendButton)
        activeBottomView.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: activeBottomView.leadingAnchor, constant: 10),
            resetButton.bottomAnchor.constraint(equalTo: activeBottomView.bottomAnchor, constant: 10),
            resetButton.heightAnchor.constraint(equalToConstant: 64),
            resetButton.widthAnchor.constraint(equalToConstant: 64),
            
            sendButton.trailingAnchor.constraint(equalTo: activeBottomView.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: activeBottomView.bottomAnchor, constant: 10),
            sendButton.heightAnchor.constraint(equalToConstant: 64),
            sendButton.widthAnchor.constraint(equalToConstant: 64)
        ])
        
    }
    
    private func recButtonTapped() {
        self.recording.toggle()
        print("Recording started!")
    }
    
    private func endSession() {
        recording.toggle()
        saveCurrentSession()
        print("Recording stopped")
    }
    
    private func saveCurrentSession() {
        print("Session saved")
    }

}

