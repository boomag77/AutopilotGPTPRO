
import StoreKit

protocol TransactionObserverDelegate: AnyObject {
    var hasActiveSubscription: Bool { get set }
}

//class TransactionObserver: NSObject, SKPaymentTransactionObserver {
//    
//    weak var delegate: TransactionObserverDelegate?
//    
//    override init() {
//        super.init()
//        SKPaymentQueue.default().add(self)
//    }
//    
//    deinit {
//        SKPaymentQueue.default().remove(self)
//    }
//    
//    // Called whenever there is a change in the payment queue
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased:
//                // Handle the purchased transaction
//                    delegate?.hasActiveSubscription = true
//                print("Transaction purchased: \(transaction)")
//                SKPaymentQueue.default().finishTransaction(transaction)
//            case .failed:
//                // Handle failed transaction
//                
//                print("Transaction failed: \(transaction.error?.localizedDescription ?? "Unknown error")")
//                SKPaymentQueue.default().finishTransaction(transaction)
//            case .restored:
//                // Handle restored transaction
//                    delegate?.hasActiveSubscription = true
//                print("Transaction restored: \(transaction)")
//                SKPaymentQueue.default().finishTransaction(transaction)
//            case .deferred, .purchasing:
//                // Handle deferred and purchasing states
//                print("Transaction state deferred or purchasing")
//            @unknown default:
//                print("Unknown transaction state")
//            }
//        }
//    }
//}

class TransactionObserver {
    
    var transactionUpdatesCancellable: Task<Void, Never>?
    
    init() {
        startObservingTransactionUpdates()
    }
    
    deinit {
        print("Observer has been deinitialized")
        transactionUpdatesCancellable?.cancel()
    }

    
    private func startObservingTransactionUpdates() {
        transactionUpdatesCancellable = Task {
            for await update in Transaction.updates {
                switch update {
                    case .verified(let transaction):
                        //print("Transaction UPDATE: \(transaction)")
                        await handleVerifiedTransaction(transaction)
                        await transaction.finish()
                    case .unverified(let transaction, let error):
                        handleUnverifiedTransaction(transaction, error: error)
                        print("Transaction Observer -> Transaction verification error: \(error.localizedDescription)")
                        await transaction.finish()
                }
            }
        }
    }
    
    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        print("handle Verified Transaction")
        print(transaction)
        if let revocationDate = transaction.revocationDate, revocationDate <= Date() {
            // This transaction has been revoked (refunded or cancelled)
            print("Transaction revoked for product ID: \(transaction.productID)")
            await revokeAccess(for: transaction.productID)
        } else if let expDate = transaction.expirationDate, expDate <= Date() {
            // The subscription has expired
            print("Subscription expired for product ID: \(transaction.productID)")
            await expireSubscription(for: transaction.productID)
        } else {
            // Handle active or renewed subscription
            print("checking ownershipType")
            switch transaction.ownershipType {
            case .purchased:
                print("Product purchased: \(transaction.productID)")
                await unlockPurchase(for: transaction.productID)
                    
            case .familyShared:
                print("Product shared via Family Sharing: \(transaction.productID)")
                await unlockPurchase(for: transaction.productID)
            default:
                break
            }
        }
        // Finish the transaction to confirm that it has been handled
        print("Finishing transaction")
        await transaction.finish()
    }
    
    private func handleUnverifiedTransaction(_ transaction: Transaction, error: Error) {
        print("Transaction Observer -> Unverified transaction for product ID: \(transaction.productID), error: \(error.localizedDescription)")
        // Optionally, handle or log the error more robustly
    }
    
    @MainActor private func unlockPurchase(for productID: String) {
        // Logic to unlock purchased product
        SubscriptionManager.shared.hasActiveSubscription = true
        print("Unlocking product for ID: \(productID)")
    }

    @MainActor private func revokeAccess(for productID: String) {
        // Logic to revoke access to a product
        SubscriptionManager.shared.hasActiveSubscription = false
        print("Revoking access for ID: \(productID)")
    }

    @MainActor private func expireSubscription(for productID: String) {
        // Logic to handle expired subscriptions
        SubscriptionManager.shared.hasActiveSubscription = false
        print("Expiring subscription for ID: \(productID)")
    }
}
