
import UIKit

class DottedLineView: UIView {
    
    private var shapeLayer: CAShapeLayer?
    
    private var isCompleted: Bool {
        didSet {
            updateStrokeColor()
        }
    }

    override init(frame: CGRect) {
        self.isCompleted = false
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        if shapeLayer == nil {
            shapeLayer = CAShapeLayer()
            shapeLayer?.strokeColor = UIColor.systemGray.cgColor
            shapeLayer?.lineWidth = 1
            shapeLayer?.lineDashPattern = [6, 3]
            layer.addSublayer(shapeLayer!)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer?.frame = bounds
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: bounds.midX, y: 0), CGPoint(x: bounds.midX, y: bounds.height)])
        shapeLayer?.path = path
    }
    
    private func updateStrokeColor() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            shapeLayer?.strokeColor = isCompleted ? AppConstants.Color.bloombergBlue.cgColor : UIColor.systemGray.cgColor
            shapeLayer?.lineWidth = isCompleted ? 2 : 1
        }
    }
    
    func setCompleted() {
        self.isCompleted = true
    }
    
}
