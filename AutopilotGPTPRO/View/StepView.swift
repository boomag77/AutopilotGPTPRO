
import UIKit


class StepView: UIView {
    
    private let labelFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    
    private var isCompleted: Bool {
        didSet {
            updateCircleViewAppearance()
        }
    }
    
    private var isProcessing: Bool
    
    lazy var circleView: UIImageView = {
        let circleView = UIImageView()
        circleView.layer.borderWidth = 1
        circleView.contentMode = .scaleAspectFit
        circleView.layer.borderColor = UIColor.clear.cgColor
        circleView.translatesAutoresizingMaskIntoConstraints = false
        return circleView
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var linkLine: DottedLineView = {
        let line = DottedLineView()
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemGray
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    init(text: String, isCompleted: Bool) {
        self.isCompleted = isCompleted
        self.isProcessing = false
        super.init(frame: .zero)
        setupView(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(text: String) {
        
        addSubview(circleView)
        addSubview(label)
        label.text = text
        
        let constraints: [NSLayoutConstraint] = [
            // Adaptive size for circleView
            circleView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0),
            circleView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0),
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        updateCircleViewAppearance()
    }
    
    private func updateCircleViewAppearance() {
        
        UIView.animate(withDuration: 0.5) { [unowned self] in
            circleView.layer.borderColor = isCompleted ? AppConstants.Color.bloombergBlue.cgColor : UIColor.systemGray.cgColor
            circleView.image = isCompleted ? UIImage(systemName: "checkmark.circle.fill") : nil
            circleView.tintColor = isCompleted ? AppConstants.Color.bloombergBlue : .clear
            circleView.backgroundColor = isCompleted ? .white.withAlphaComponent(0.85) : .clear
            label.textColor = isCompleted ? .white : .systemGray
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
    func setCompleted() {
        if self.isProcessing {
            circleView.layer.borderWidth = 2
            activityIndicator.stopAnimating()
            self.isProcessing = false
        }
        self.isCompleted = true
    }
    
    func startProcessing() {
        circleView.layer.borderWidth = 0
        circleView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
        activityIndicator.startAnimating()
        self.isProcessing = true
    }
    
    
    
}
