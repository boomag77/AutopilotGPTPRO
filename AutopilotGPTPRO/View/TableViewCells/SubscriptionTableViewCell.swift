import UIKit


class SubscriptionTableViewCell: UITableViewCell {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var price: String? {
        didSet {
            descriptionLabel.text = "Full access for only \(price!)/month"
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        //label.font = boldTitleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var selectedMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        //vimageView.layer.borderWidth = 0.5
        //imageView.layer.borderColor = UIColor.label.withAlphaComponent(0.5).cgColor
        imageView.tintColor = AppConstants.Color.bloombergBlue
        imageView.backgroundColor = .systemBackground
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedMark.layer.cornerRadius = selectedMark.bounds.size.height / 2
    }
    
    private func setupViews() {
        
        backgroundColor = .systemGray6
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppConstants.Color.bloombergBlue.cgColor
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        setupConstraints()
        
        contentView.addSubview(selectedMark)
        NSLayoutConstraint.activate([
            selectedMark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            selectedMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectedMark.heightAnchor.constraint(equalToConstant: 20),
            selectedMark.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    
}
