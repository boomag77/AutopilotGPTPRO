
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
    
    private lazy var editOrCreateView: UIView = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
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
        self.view.insertSubview(editOrCreateView, at: 1)
        
        NSLayoutConstraint.activate([
            listView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            listView.topAnchor.constraint(equalTo: controllerTitle.bottomAnchor),
            listView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            editOrCreateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            editOrCreateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            editOrCreateView.topAnchor.constraint(equalTo: controllerTitle.bottomAnchor),
            editOrCreateView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
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
        
        let exitButton = UIButton(type: .system)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.title = "Back"
        config.baseBackgroundColor = UIColor.systemBlue
        config.baseForegroundColor = .white.withAlphaComponent(0.85)
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        config.cornerStyle = .large
        exitButton.configuration = config
        exitButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        editOrCreateView.addSubview(exitButton)
        NSLayoutConstraint.activate([
            exitButton.centerXAnchor.constraint(equalTo: editOrCreateView.centerXAnchor),
            exitButton.centerYAnchor.constraint(equalTo: editOrCreateView.centerYAnchor)
        ])
        
        
        editOrCreateView.isHidden = true
        fetchData()
    }
    
    private func fetchData() {
        instructions = DataManager.shared.getInstructions()
        tableView.reloadData()
    }
    
    @objc private func addNewButtonTapped() {
        print("Add new Button pressed")
        editOrCreateView.isHidden.toggle()
        listView.isHidden.toggle()
    }
    
    @objc private func backButtonTapped() {
        editOrCreateView.isHidden.toggle()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell")
        var content = cell?.defaultContentConfiguration()
        content?.text = instructions[indexPath.row].name
        cell?.contentConfiguration = content
        return cell!
    }
    
    
}

