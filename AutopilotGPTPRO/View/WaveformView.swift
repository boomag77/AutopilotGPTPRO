
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
        let gap: CGFloat = 1
        let barWidth = (rect.width / CGFloat(powerLevels.count)) - gap
        let middleY = rect.height / 2
        for (index, level) in powerLevels.enumerated() {
            
            let normalizedLevel = max(0.05, CGFloat(level) / 40 + 1)
            let x = (CGFloat(index) * (barWidth + gap)) + gap/2
            let barHeight = normalizedLevel * middleY / 2
            
            let barRect = CGRect(x: x, y: (middleY - barHeight), width: barWidth, height: barHeight)
            context.addRect(barRect)

            let mirroredBarRect = CGRect(x: x, y: middleY, width: barWidth, height: barHeight)
            context.addRect(mirroredBarRect)
        }
        context.setFillColor(UIColor.systemGreen.withAlphaComponent(0.5).cgColor)
        context.fillPath()
    }

}
