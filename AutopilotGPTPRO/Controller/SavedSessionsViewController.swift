
import UIKit

class SavedSessionsViewController: UIViewController {
    
    private var sessions: [SessionModel] = [SessionModel(id: 1, date: Date(), position: "Pos1"), SessionModel(id: 2, date: Date(), position: "Pos2")]
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SessionTableViewCell.self, forCellReuseIdentifier: "SessionCell")
        fetchData()
        setup()
        
    }
    
    private func fetchData() {
        sessions = DataManager.shared.getSessions(sortKey: "date", ascending: true)
        tableView.reloadData()
    }
    
    private func setup() {
        view.backgroundColor = .systemGray6
        
        let screenTitle = ScreenTitleLabel(withText: "Sessions")
        
        view.addSubview(screenTitle)
        screenTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        screenTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
}

extension SavedSessionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return DataManager.shared.getSessionsCount()
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let session = sessions[indexPath.row]
        let positionName = session.position
        let date = session.date
        let id = session.id
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell",
                                                 for: indexPath) as! SessionTableViewCell
        cell.setTitle(title: positionName)
        cell.setDate(date: date)
        cell.setIdNumber(id: id)
        
        return cell
    }
    
    
}

extension SavedSessionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSession = sessions[indexPath.row]
        print("Selected Session with id: \(selectedSession.id)")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _,_,_ in
            
            let sessionToRemove: SessionModel = self!.sessions[indexPath.row]
            DataManager.shared.removeSession(withID: sessionToRemove.id) {
                self?.fetchData()
            }
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }
    
}

extension SavedSessionsViewController: TabBarDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        tableView.dataSource = self
        fetchData()
        setup()
    }
    
    
}
