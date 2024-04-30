
import UIKit

protocol TabBarDelegate: UIViewController {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
}

final class TabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setup()
    }
    
    private func setup() {
        
        tabBar.backgroundColor = .systemBackground
        
        let instructionsVC = InstructionsViewController()
        instructionsVC.tabBarItem = UITabBarItem(title: "Instructions",
                                                 image: UIImage(systemName: "mic"),
                                                 selectedImage: nil)
        let firstNavController = UINavigationController(rootViewController: instructionsVC)
        
        let sessionsVC = SavedSessionsViewController()
        sessionsVC.tabBarItem = UITabBarItem(title: "Saved sessions",
                                             image: UIImage(systemName: "bubble.left.and.bubble.right"),
                                             selectedImage: nil)
        let secondNavController = UINavigationController(rootViewController: sessionsVC)
        
//        let settingsVC = SettingsViewController()
//        settingsVC.tabBarItem = UITabBarItem(title: "Settings",
//                                             image: UIImage(systemName: "gearshape"),
//                                             selectedImage: nil)
        
        viewControllers = [firstNavController, secondNavController]
        
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
