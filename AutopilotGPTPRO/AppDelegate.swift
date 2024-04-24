
import UIKit
import CoreData
import Adapty

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = AppDelegate()
    
    var isSubscriptionActive: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        
        let font: UIFont
        if let boldFontDescriptor = boldFontDescriptor {
            font = UIFont(descriptor: boldFontDescriptor, size: 0)
        } else {
            font = UIFont.preferredFont(forTextStyle: .largeTitle)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let textAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.label.withAlphaComponent(0.85),
        ]
        
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        
        Adapty.activate("public_live_WYY01n3D.ZUfI44hzp0oVAK15wAH6")
        Adapty.logLevel = .warn
        
        AdaptyManager.shared.checkAccess { result in
            self.isSubscriptionActive = true
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: CoreData
    
    

}

extension AppDelegate: AdaptyDelegate {
    
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        guard let accessLevel = profile.accessLevels ["monthly"] else {
            return
        }
        self.isSubscriptionActive = accessLevel.isActive
    }
    
}

