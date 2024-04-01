
import UIKit

class CurrentSessionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setup() {
        view.backgroundColor = .black
    }

}
