import UIKit

class VerticalDottedProgressView: UIView {

    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    var progress: Float = 0 {
        didSet {
            setNeedsLayout()
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
    
    private func setup() {
        
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(progressLayer)
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 1.0
        trackLayer.lineDashPattern = [10.0, 10.0]
        trackLayer.fillColor = nil
        
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.lineWidth = 1.0
        progressLayer.lineDashPattern = [10.0, 10.0]
        progressLayer.fillColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX, y: 0))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.height))
        
        trackLayer.path = path.cgPath
        trackLayer.frame = bounds
        
        let progressPath = UIBezierPath()
        let progressHeight = bounds.height * CGFloat(progress)
        progressPath.move(to: CGPoint(x: bounds.midX, y: bounds.height))
        progressPath.addLine(to: CGPoint(x: bounds.midX, y: bounds.height - progressHeight))
        
        progressLayer.path = progressPath.cgPath
        progressLayer.frame = bounds
    }
}
