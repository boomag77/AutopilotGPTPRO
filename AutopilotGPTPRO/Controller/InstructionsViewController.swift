
import UIKit

final class InstructionsViewController: UIViewController {
    
    private var instructions: [InstructionModel] = []
    
    private lazy var screenTitle: UILabel = {
        let label = ScreenTitleLabel(withText: "Instructions")
        return label
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
        button.addTarget(self, action: #selector(self.addNewButtonPressed), for: .touchUpInside)
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
        
        view.addSubview(screenTitle)
        view.addSubview(addNewButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            screenTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            screenTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            
            addNewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            addNewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            addNewButton.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 10.0),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            tableView.topAnchor.constraint(equalTo: addNewButton.bottomAnchor, constant: 10.0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0)
        ])
        
    }
    
    private func fetchData() {
        instructions = DataManager.shared.getInstructions()
        tableView.reloadData()
    }
    
    @objc private func addNewButtonPressed() {
        print("Add new Button pressed")
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

