
import UIKit

class WaveformView: UIView {

    var powerLevels: [CGFloat] = [] {
        didSet {
            DispatchQueue.main.async { self.setNeedsDisplay() }
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(rect)
        context.setFillColor(UIColor.black.cgColor)
        context.fill(rect)

        // Drawing code here
        let path = UIBezierPath()
        let middleY = rect.height / 2
        for (index, level) in powerLevels.enumerated() {
            let normalizedLevel = max(0.2, CGFloat(level) / 160 + 1) // Normalize
            let x = CGFloat(index) * (rect.width / CGFloat(powerLevels.count))
            let y = middleY - normalizedLevel * middleY / 2
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        UIColor.green.setStroke()
        path.stroke()
    }

}
