

import UIKit

protocol TabBarDelegate: UIViewController {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
}

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setup()
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        
        let instructionsVC = InstructionsViewController()
        instructionsVC.tabBarItem = UITabBarItem(title: "Instructions",
                                                 image: UIImage(systemName: "mic"),
                                                 selectedImage: nil)
        let sessionsVC = SessionsViewController()
        sessionsVC.tabBarItem = UITabBarItem(title: "Saved sessions",
                                             image: UIImage(systemName: "bubble.left.and.bubble.right"),
                                             selectedImage: nil)
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings",
                                             image: UIImage(systemName: "gearshape"),
                                             selectedImage: nil)
        
        viewControllers = [instructionsVC, sessionsVC, settingsVC]
        
        tabBarController(self, didSelect: instructionsVC)
    }
    

}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let selectedVC = viewController as? TabBarDelegate {
            selectedVC.tabBarController(tabBarController, didSelect: viewController)
        }
    }
}
