
import UIKit

class SubscriptionTableViewCell: UITableViewCell {
    
    var appName: String = "GPT Autopilot for Interview"
    var localizedPrice: String?
    var name: String?
    var subscriptionDescription: String?
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
    }

}
