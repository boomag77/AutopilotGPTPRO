

import UIKit

class ErrorHandler {
    
    
    static func showAlert(title: String, message: String) {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            var presentingViewController = window.rootViewController
            while let presentedViewController = presentingViewController?.presentedViewController {
                presentingViewController = presentedViewController
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            presentingViewController?.present(alertController, animated: true, completion: nil)
        } else {
            guard let window = UIApplication.shared.keyWindow,
                  let rootViewController = window.rootViewController else {
                return
            }
            
            var presentingViewController = rootViewController
            while let presentedViewController = presentingViewController.presentedViewController {
                presentingViewController = presentedViewController
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            presentingViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
