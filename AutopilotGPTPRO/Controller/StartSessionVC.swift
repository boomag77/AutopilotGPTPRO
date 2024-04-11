
import UIKit

class StartSessionVC: UIViewController {
    
    var instruction: InstructionModel? {
        didSet {
            positionTextField.text = instruction?.name
            instructionTextTextView.text = instruction?.text
        }
    }
    
    private var checkBoxChecked: Bool = false {
        didSet {
            if checkBoxChecked {
                (checkBox as? CheckBox)?.checked = true
                var config = launchSessionButton.configuration
                config?.title = "Save and Launch Session"
                config?.baseBackgroundColor = UIColor.systemBlue
                config?.baseForegroundColor = .white.withAlphaComponent(0.85)
                config?.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
                config?.cornerStyle = .large
                config?.titleAlignment = .center
                launchSessionButton.configuration = config
                
            } else {
                (checkBox as? CheckBox)?.checked = false
                var config = launchSessionButton.configuration
                config?.title = "Launch Autopilot Session"
                config?.baseBackgroundColor = UIColor.systemBlue
                config?.baseForegroundColor = .white.withAlphaComponent(0.85)
                config?.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
                config?.cornerStyle = .large
                config?.titleAlignment = .center
                launchSessionButton.configuration = config
            }
        }
    }
    
    let positionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemBackground
        textField.textColor = .label.withAlphaComponent(0.85)
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.clearButtonMode = .always
        return textField
    }()
    
    let instructionTextTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label.withAlphaComponent(0.9)
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.keyboardDismissMode = .interactive
        
        return textView
    }()
    
    private lazy var checkBox: UIControl = {
        let box = CheckBox()
        box.addAction(UIAction { _ in
            box.checked.toggle()
            self.checkBoxChecked.toggle()
        }, for: .touchUpInside)
        return box
    }()
    
    private lazy var checkBoxLabel: UILabel = {
        let label = UILabel()
        label.text = "Save instruction"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .darkGray.withAlphaComponent(0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var launchSessionButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.title = "Launch Autopilot Session"
        config.baseBackgroundColor = UIColor.systemBlue
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        config.cornerStyle = .large
        config.titleAlignment = .center
        button.configuration = config
        
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.launchSessionButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("StartSessionVC is being deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Start Session"
        view.backgroundColor = .systemGray6
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        positionTextField.delegate = self
        
        //positionTextField.becomeFirstResponder()
    }
    
    private func setup() {
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboard))
        swipeGesture.direction = .down // Customize this based on your needs
        view.addGestureRecognizer(swipeGesture)
        
        checkBoxChecked = false
        
        if instruction == nil {
            positionTextField.isEnabled = true
            positionTextField.placeholder = "Input title here"
            positionTextField.text = nil
            instructionTextTextView.text = ""
        } else {
            positionTextField.isEnabled = true
            //positionTextField.backgroundColor = UIColor.systemGray6
            positionTextField.text = instruction?.name
            instructionTextTextView.text = instruction?.text
        }
        
        view.addSubview(positionTextField)
        view.addSubview(instructionTextTextView)
        view.addSubview(checkBox)
        view.addSubview(launchSessionButton)
        view.addSubview(checkBoxLabel)
        
        if (checkBox as? CheckBox)?.checked == true {
            (checkBox as? CheckBox)?.checked = self.checkBoxChecked
        }
        
        
        NSLayoutConstraint.activate([
            positionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0),
            positionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            positionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            
            launchSessionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            launchSessionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            launchSessionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.0),
            
            checkBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            checkBox.bottomAnchor.constraint(equalTo: launchSessionButton.topAnchor, constant: -16),
            checkBox.heightAnchor.constraint(equalToConstant: 12),
            
            checkBoxLabel.centerYAnchor.constraint(equalTo: checkBox.centerYAnchor),
            checkBoxLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 16),
            
            instructionTextTextView.topAnchor.constraint(equalTo: positionTextField.bottomAnchor, constant: 10.0),
            instructionTextTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            instructionTextTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            instructionTextTextView.bottomAnchor.constraint(equalTo: checkBox.topAnchor, constant: -16.0)
        ])
        
        if instruction == nil {
            checkBoxLabel.text = "Save new instruction"
            checkBox.isEnabled = true
        } else {
            checkBoxLabel.text = "Save instruction's changes"
            checkBox.isEnabled = true
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

}

extension StartSessionVC {
    
    private func launchSessionButtonTapped() {
        
        guard let title = positionTextField.text, let text = instructionTextTextView.text else { return }
        
        if checkBoxChecked {
            (checkBox as? CheckBox)?.checked.toggle()
            checkBoxChecked.toggle()
            saveInstruction()
        }
        
        let activeSessionVC = CurrentSessionViewController()
        
        activeSessionVC.instruction = InstructionModel(name: title, text: text)
        //hide bottom bar
        activeSessionVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(activeSessionVC, animated: true)
    }
    
    private func saveInstruction() {
        DataManager.shared
            .registerNewInstruction(instruction: InstructionModel(name: positionTextField.text!,
                                                                  text: instructionTextTextView.text)) { [weak self] in
                self?.positionTextField.text = nil
                self?.instructionTextTextView.text = nil
        }
    }
    
}

extension StartSessionVC: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        positionTextField.text = nil
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // This hides the keyboard.
        return true
    }
    
}
