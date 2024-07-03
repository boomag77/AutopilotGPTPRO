
import UIKit

class OnboardingButton: UIButton {
    
    var title: String? {
        didSet {
            if let title = title {
                setup(with: title)
            } else {
                setup(with: "not specified")
            }
            
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(with title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = AppConstants.Color.bloombergBlue
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        config.cornerStyle = .capsule
        
        let boldFont = UIFont.preferredFont(forTextStyle: .headline).bold()
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: boldFont]))
            
        self.configuration = config
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        self.titleLabel?.adjustsFontForContentSizeCategory = true
        self.clipsToBounds = true
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }

}

private extension UIFont {
    func bold() -> UIFont {
        return with(traits: .traitBold)
    }
    
    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits) ?? fontDescriptor
        return UIFont(descriptor: descriptor, size: 0)
    }
}
