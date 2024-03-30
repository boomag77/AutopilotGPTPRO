
import UIKit

class ScreenTitleLabel: UILabel {
    
    convenience init(withText text: String) {
        self.init(frame: .zero)
        self.text = text
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        textColor = .label.withAlphaComponent(0.85)
        let textStyle = UIFont.TextStyle.largeTitle
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        if let boldFontDescriptor = boldFontDescriptor {
            font = UIFont(descriptor: boldFontDescriptor, size: 0)
        } else {
            font = UIFont.preferredFont(forTextStyle: textStyle)
        }
        adjustsFontForContentSizeCategory = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
