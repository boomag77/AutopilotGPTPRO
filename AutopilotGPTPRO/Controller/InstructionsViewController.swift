
import UIKit

final class InstructionsViewController: UIViewController {
    
    private var instructions: [InstructionModel] = []
    
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
    
    private lazy var controllerTitle: UILabel = {
        let label = ScreenTitleLabel(withText: "Instructions")
        return label
    }()
    
    private lazy var listView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var instructionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var addNewButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.title = "Create New Instruction"
        config.baseBackgroundColor = UIColor.systemBlue
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        config.cornerStyle = .large
        button.configuration = config
        
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.addNewButtonTapped), for: .touchUpInside)
        return button
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let titleField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        return textField
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label.withAlphaComponent(0.9)
        textView.isScrollEnabled = true
        textView.isEditable = true
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(InstructionTableViewCell.self, forCellReuseIdentifier: "InstructionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
        fetchData()
    }
    
    
    private func setup() {
        
        view.backgroundColor = .systemGray6
        
        self.title = "Instructions"
        
        setupViews()
        
    }
    
    private func setupViews() {
        
        self.view.addSubview(listView)
        self.view.addSubview(instructionView)
        //self.view.insertSubview(instructionView, at: 0)
        
        NSLayoutConstraint.activate([
            listView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            listView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            listView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            instructionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            instructionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            instructionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            instructionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        listView.addSubview(addNewButton)
        listView.addSubview(tableView)
        NSLayoutConstraint.activate([
            addNewButton.leadingAnchor.constraint(equalTo: listView.leadingAnchor, constant: 16.0),
            addNewButton.trailingAnchor.constraint(equalTo: listView.trailingAnchor, constant: -16.0),
            addNewButton.topAnchor.constraint(equalTo: listView.topAnchor, constant: 10.0),
            
            tableView.leadingAnchor.constraint(equalTo: listView.leadingAnchor, constant: 16.0),
            tableView.trailingAnchor.constraint(equalTo: listView.trailingAnchor, constant: -16.0),
            tableView.topAnchor.constraint(equalTo: addNewButton.bottomAnchor, constant: 10.0),
            tableView.bottomAnchor.constraint(equalTo: listView.bottomAnchor, constant: -16.0)
        ])
        
        listView.isHidden = false
        instructionView.isHidden = true
        fetchData()
    }
    
    private func setupInstructionView(instruction: InstructionModel? = nil) {
        
        checkBoxChecked = false
        
        if instruction == nil {
            titleField.isEnabled = true
            titleField.placeholder = "Input title here"
            titleField.text = nil
            textView.text = ""
        } else {
            //titleField.isEnabled = false
            titleField.backgroundColor = UIColor.systemGray6
            titleField.text = instruction?.name
            textView.text = instruction?.text
        }
        
        instructionView.addSubview(titleField)
        instructionView.addSubview(textView)
        instructionView.addSubview(checkBox)
        instructionView.addSubview(launchSessionButton)
        instructionView.addSubview(checkBoxLabel)
        
        if (checkBox as? CheckBox)?.checked == true {
            (checkBox as? CheckBox)?.checked = self.checkBoxChecked
        }
        
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: instructionView.topAnchor, constant: 10.0),
            titleField.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 16.0),
            titleField.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -16.0),
            
            launchSessionButton.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 16.0),
            launchSessionButton.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -16.0),
            launchSessionButton.bottomAnchor.constraint(equalTo: instructionView.bottomAnchor, constant: -10.0),
            
            checkBox.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 26),
            checkBox.bottomAnchor.constraint(equalTo: launchSessionButton.topAnchor, constant: -16),
            checkBox.heightAnchor.constraint(equalToConstant: 12),
            
            checkBoxLabel.centerYAnchor.constraint(equalTo: checkBox.centerYAnchor),
            checkBoxLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 16),
            
            textView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10.0),
            textView.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 16.0),
            textView.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -16.0),
            textView.bottomAnchor.constraint(equalTo: checkBox.topAnchor, constant: -16.0)
        ])
        
        if instruction == nil {
            checkBoxLabel.text = "Save new instruction"
            checkBox.isEnabled = true
        } else {
            checkBoxLabel.text = "Save instruction's changes"
            checkBox.isEnabled = true
        }
    }
    
    private func fetchData() {
        instructions = DataManager.shared.getAllInstructions()
        tableView.reloadData()
    }
    
    @objc private func addNewButtonTapped() {
        setupInstructionView()
        instructionView.isHidden.toggle()
        listView.isHidden.toggle()
    }
    
    func createSaveButtonAction() -> UIAction {
        return UIAction { [weak self] _ in
            self?.saveInstruction()
        }
    }
    
    private func saveInstruction() {
        DataManager.shared
            .registerNewInstruction(instruction: InstructionModel(name: titleField.text!,
                                                                  text: textView.text)) { [weak self] in
                self?.titleField.text = nil
                self?.textView.text = nil
                self?.instructionView.isHidden.toggle()
                self?.listView.isHidden.toggle()
                self?.fetchData()
        }
    }
    
//    private func cancelButtonTapped() {
//        instructionView.isHidden.toggle()
//        listView.isHidden.toggle()
//        fetchData()
//    }
    
    private func launchSessionButtonTapped() {
        if checkBoxChecked {
            (checkBox as? CheckBox)?.checked.toggle()
            checkBoxChecked.toggle()
            saveInstruction()
        }
        let sessionViewController = CurrentSessionViewController()
        sessionViewController.position = titleField.text
        sessionViewController.instruction = textView.text
        //hide bottom bar
        sessionViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(sessionViewController, animated: true)
    }

}

extension InstructionsViewController: TabBarDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        fetchData()
        setup()
    }
}

extension InstructionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let instructionName = self.instructions[indexPath.row].name
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell",
                                                 for: indexPath) as! InstructionTableViewCell
        cell.titleText = instructionName
        
        return cell
    }
}

extension InstructionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedInstruction = self.instructions[indexPath.row]
        setupInstructionView(instruction: selectedInstruction)
        instructionView.isHidden.toggle()
        listView.isHidden.toggle()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _,_,_ in
            
                let instructionForRemove: InstructionModel = self!.instructions[indexPath.row]
            
                DataManager.shared.removeInstruction(instruction: instructionForRemove) {
                    self?.fetchData()
                }
        }
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }
//    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        //
//    }
    
}

