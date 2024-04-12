
import UIKit

final class SavedSessionsViewController: UIViewController {
    
    private var sessions: [SessionModel] = []
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor  = .systemGray6
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SessionTableViewCell.self, forCellReuseIdentifier: "SessionCell")
        //fetchData()
        setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        
        // hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar on child controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func fetchData() {
        sessions = DataManager.shared.getSessions(sortKey: "date", ascending: false)
        tableView.reloadData()
    }
    
    private func setup() {
        view.backgroundColor = .systemGray6
        
        self.title = "Sessions"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
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
        let messagesCount = DataManager.shared.getMessagesCount(forSessionID: id)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell",
                                                 for: indexPath) as! SessionTableViewCell
        cell.setTitle(title: positionName)
        cell.setDate(date: date)
        cell.setIdNumber(id: id)
        cell.setMessagesCount(count: messagesCount)
        
        return cell
    }
    
    
}

extension SavedSessionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSession = sessions[indexPath.row]
        
        let sessionVC = SavedSessionMessagesVC()
        
        sessionVC.setSessionID(selectedSession.id)
        sessionVC.title = selectedSession.position
        //hide bottom bar
        sessionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(sessionVC, animated: true)
        
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
//        fetchData()
//        setup()
    }
    
    
}
