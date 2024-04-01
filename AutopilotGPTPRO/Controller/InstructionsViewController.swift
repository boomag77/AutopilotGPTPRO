
import UIKit

final class InstructionsViewController: UIViewController {
    
    private var instructions: [InstructionModel] = []
    
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGray6
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
        textView.backgroundColor = .white
        textView.isScrollEnabled = true
        textView.isEditable = true
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "InstructionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    
    private func setup() {
        
        view.backgroundColor = .systemGray6
        
        view.addSubview(controllerTitle)
        
        NSLayoutConstraint.activate([
            controllerTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            controllerTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            controllerTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0)
        ])
        setupViews()
        
    }
    
    private func setupViews() {
        
        self.view.addSubview(listView)
        self.view.insertSubview(instructionView, at: 0)
        
        NSLayoutConstraint.activate([
            listView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            listView.topAnchor.constraint(equalTo: controllerTitle.bottomAnchor),
            listView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            instructionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            instructionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            instructionView.topAnchor.constraint(equalTo: controllerTitle.bottomAnchor),
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
        
        instructionView.isHidden = true
        fetchData()
    }
    
    private func setupInstructionView(instruction: InstructionModel? = nil) {
        
        if instruction == nil {
            titleField.isEnabled = true
            titleField.placeholder = "Input title here"
            titleField.text = nil
            textView.text = ""
        } else {
            titleField.isEnabled = false
            titleField.text = instruction?.name
            textView.text = instruction?.text
        }
        
        let saveButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            var config = UIButton.Configuration.filled()
            config.title = "Save"
            config.baseBackgroundColor = UIColor.systemBlue
            config.baseForegroundColor = UIColor.white.withAlphaComponent(0.85)
            config.cornerStyle = .large
            button.configuration = config
            button.addAction(createSaveButtonAction(), for: .touchUpInside)
            return button
        }()
        
        let cancelButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            var config = UIButton.Configuration.filled()
            config.title = "Cancel"
            config.baseBackgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
            config.baseForegroundColor = UIColor.white.withAlphaComponent(0.85)
            config.cornerStyle = .large
            button.configuration = config
            button.addAction(UIAction { [weak self] _ in
                self?.cancelButtonTapped()
            }, for: .touchUpInside)
            return button
        }()
        
        let buttonsStack: UIStackView = {
            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.addArrangedSubview(saveButton)
            stack.addArrangedSubview(cancelButton)
            return stack
        }()
        
        instructionView.addSubview(titleField)
        instructionView.addSubview(textView)
        instructionView.addSubview(buttonsStack)
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: instructionView.topAnchor, constant: 10.0),
            titleField.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 16.0),
            titleField.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -16.0),
            
            buttonsStack.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 16.0),
            buttonsStack.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -16.0),
            buttonsStack.bottomAnchor.constraint(equalTo: instructionView.bottomAnchor, constant: -10.0),
            
            textView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10.0),
            textView.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 16.0),
            textView.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -16.0),
            textView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -10.0)
        ])
        
        
        
    }
    
    private func fetchData() {
        instructions = DataManager.shared.getInstructions()
        tableView.reloadData()
    }
    
    @objc private func addNewButtonTapped() {
        setupInstructionView()
        instructionView.isHidden.toggle()
        listView.isHidden.toggle()
    }
    
    func createSaveButtonAction() -> UIAction {
        return UIAction { [weak self] _ in
            self?.saveButtonTapped()
        }
    }
    
    private func saveButtonTapped() {
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
    
    private func cancelButtonTapped() {
        instructionView.isHidden.toggle()
        listView.isHidden.toggle()
        fetchData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = instructions[indexPath.row].name
        cell.contentConfiguration = content
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
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        //
//    }
//    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        //
//    }
    
}

