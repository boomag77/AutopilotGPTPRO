

import UIKit

class CheckBox: UIControl {

    private weak var imageView: UIImageView!
    
    private lazy var touchableInset: CGFloat = {
        let minimumTouchableArea: CGFloat = 44
        let horizontalInset = max(0, (minimumTouchableArea - frame.width) / 2)
        let verticalInset = max(0, (minimumTouchableArea - frame.height) / 2)
        
        // Return the largest inset required to ensure the view is at least 44x44 points tappable.
        return max(horizontalInset, verticalInset)
    }()
        
    private var image: UIImage {
        return checked ? UIImage(systemName: "checkmark.square.fill")! :
                        UIImage(systemName: "square")!
    }
    
    var checked: Bool = false {
        didSet {
            imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Increase the hit frame to be larger than the visible frame of the view
        let hitFrame = bounds.insetBy(dx: -touchableInset, dy: -touchableInset)
        return hitFrame.contains(point)
    }
    
    private func setup() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive =  true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        imageView.image = self.image
        imageView.contentMode = .scaleAspectFill
        
        self.imageView = imageView
        
        backgroundColor = UIColor.clear
        
    }

}
