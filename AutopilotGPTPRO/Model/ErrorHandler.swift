

import UIKit

class ErrorHandler {
    
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handleError(_ error: AutopilotError, on viewController: UIViewController?, retryAction: (() async  -> Void)?) {
        let alert = UIAlertController(title: error.title, message: error.description, preferredStyle: .alert)
        
        // 'OK' action
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // Optionally add a 'Retry' action if the error specifies it
        if let retryAction = retryAction {
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                Task {
                    await retryAction()
                }
            }))
        }

        DispatchQueue.main.async {
            viewController?.present(alert, animated: true)
        }
    }
    
    
}
