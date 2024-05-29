
import UIKit
import CoreData
import Adapty

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = AppDelegate()
    
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
        
        Adapty.delegate = PurchasesObserver.shared
        //Adapty.logLevel = .verbose
        Adapty.activate(AppConstants.adaptyApiKey) { _ in
            PurchasesObserver.shared.loadInitialProfileData()
            PurchasesObserver.shared.loadInitialPaywallData()
        }

        // in case you have / want to use fallback paywalls
//        if let urlPath = Bundle.main.url(forResource: "fallback_paywalls", withExtension: "json"),
//           let paywallsData = try? Data(contentsOf: urlPath) {
//            Adapty.setFallbackPaywalls(paywallsData) { _ in
//                // handle error
//            }
//        }
        
        
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}
