
import UIKit

class OnboardingTableViewCell: UITableViewCell {
    
    var title: String? {
        didSet {
            self.titleLabel.text = title
            updateCellViewConstraints()
            updatePaddingConstraints()
        }
    }
    
    var checked: Bool = false {
        didSet {
            checkMark.image = image
        }
    }
    
    private var paddingConstraints: [NSLayoutConstraint] = []
    private var cellViewConstraints: [NSLayoutConstraint] = []
    
    private var image: UIImage? {
        let image = self.checked ? UIImage(systemName: "checkmark.circle.fill") :
                                    UIImage(systemName: "circle")
        return image
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.85)
        label.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var checkMark: UIImageView = {
        let view = UIImageView()
        view.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.image = image
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 245/255, green: 250/255, blue: 255/255, alpha: 1.0)
        
        //UIColor(red: 245, green: 250, blue: 255, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setup() {
        
        //contentView.backgroundColor = .systemBackground
        if traitCollection.userInterfaceStyle == .light {
            // Light mode
            contentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 242/255, alpha: 1.0)
        } else {
            // Dark mode or unspecified
            contentView.backgroundColor = UIColor.systemGray6
        }
        contentView.addSubview(cellView)
        setupCellView()
    }
    
    private func setupCellView() {
        cellView.addSubview(checkMark)
        cellView.addSubview(titleLabel)
    }
    
    private func updatePaddingConstraints() {
        
        let padding: CGFloat = 6
        
        NSLayoutConstraint.deactivate(paddingConstraints)
        paddingConstraints = [
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(paddingConstraints)
    }
    
    private func updateCellViewConstraints() {
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.deactivate(cellViewConstraints)
        cellViewConstraints = [
            checkMark.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: padding),
            checkMark.topAnchor.constraint(equalTo: cellView.topAnchor, constant: padding),
            checkMark.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -padding),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkMark.trailingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellView.trailingAnchor, constant: -padding),
            titleLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(cellViewConstraints)
    }

}
