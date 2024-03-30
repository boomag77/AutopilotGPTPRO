
import UIKit

class SessionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        let screenTitle = ScreenTitleLabel(withText: "Sessions")
        
        view.addSubview(screenTitle)
        screenTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        screenTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
    }
    
}

extension SessionsViewController: TabBarDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        setup()
    }
    
    
}
