
import UIKit

class StartViewController: UIViewController {
    
    lazy var screenName: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        screenName.text = "Start Screen"
        view.addSubview(screenName)
        screenName.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        screenName.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
