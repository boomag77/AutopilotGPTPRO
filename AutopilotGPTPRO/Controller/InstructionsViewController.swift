
import UIKit

final class InstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        
        view.backgroundColor = .systemBackground
        let screenTitle = ScreenTitleLabel(withText: "Instructions")
        
        view.addSubview(screenTitle)
        screenTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
        screenTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
    }

}

extension InstructionsViewController: TabBarDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        setup()
    }
    
    
}
