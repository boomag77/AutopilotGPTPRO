import UIKit

class ReviewView: UIView {
    
    private let maxRating: Int = 5
    private var review: Review

    init(_ review: Review) {
        self.review = review
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var ratingView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        for _ in 0..<maxRating {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "star.fill")
            imageView.tintColor = AppConstants.Color.bloombergBlue.withAlphaComponent(0.8)
            imageView.contentMode = .scaleAspectFit
            
            stackView.addArrangedSubview(imageView)
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .systemGray.withAlphaComponent(0.8)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.text = self.review.name
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label.withAlphaComponent(0.8)
        label.minimumScaleFactor = 0.5
        label.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
        label.text = self.review.title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .vertical)
        label.textColor = .label.withAlphaComponent(0.8)
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.text = self.review.text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 20
        backgroundColor = .systemGray4
        
        addSubview(ratingView)
        addSubview(nameLabel)
        addSubview(titleLabel)
        addSubview(textLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Constraints for ratingView
            ratingView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            ratingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            
            // Constraints for nameLabel
            nameLabel.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            // Constraints for titleLabel
            titleLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            // Constraints for textLabel
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15)
        ])
    }
}
