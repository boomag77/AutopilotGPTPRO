
import UIKit
import CoreData
import Adapty

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = AppDelegate()
    
//    var hasActiveSubscription: Bool = false {
//        didSet {
//            print("AppDelegate subscription state - \(hasActiveSubscription)")
//        }
//    }
    
    //var subscriptionManager = SubscriptionManager()
    //var transactionObserver: TransactionObserver?
    //var store = Store()
    
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
        
        //checkSubscriptionStatus()
        
        //   ADAPTY STARTING
        
        Adapty.activate("public_live_eitcXPrT.V7zWesNyCbnYWxtbU4E6")
        Adapty.logLevel = .verbose
        //   ADAPTY STARTING
//        self.hasActiveSubscription = subscriptionManager.hasProKey
//        

//        SubscriptionManager.shared.checkForActiveSubscription { result in
//            switch result {
//                case .success(let status):
//                    //self.hasActiveSubscription = status
//                    print(status)
//                case .failure(let error):
//                    print(error.localizedDescription)
//            }
//        }
//        
//        self.transactionObserver = TransactionObserver()
        
        
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
        
        //transactionObserver = nil
    }
    
//    private func checkSubscriptionStatus() {
//        
//        SubscriptionManager.shared.checkForActiveSubscription { result in
//            switch result {
//                case .success(let status):
//                    self.hasActiveSubscription = status
//                    print("AppDelegate -> Subscription status is \(status)")
//                case .failure(let error):
//                    print("AppDelegate -> Error: Failed to check subscription status: \(error.localizedDescription)")
//            }
//        }
//        
//    }
    
    //MARK: CoreData
    
    

}
