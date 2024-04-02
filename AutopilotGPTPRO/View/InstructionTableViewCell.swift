
import UIKit

class InstructionTableViewCell: UITableViewCell {
    
    private var padding: CGFloat = 2
    
    var titleText: String? {
        didSet {
            titleLabel.text = titleText
            updateCellViewConstraints()
            updatePaddingConstraints()
        }
    }
    
    private var paddingConstraints: [NSLayoutConstraint] = []
    private var cellViewConstraints: [NSLayoutConstraint] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label.withAlphaComponent(0.85)
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chevronImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "chevron.forward")
        view.tintColor = .systemGray.withAlphaComponent(0.85)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .systemBackground
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
    
    private func updatePaddingConstraints() {
        
        NSLayoutConstraint.deactivate(paddingConstraints)
        paddingConstraints = [
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(paddingConstraints)
        
        layoutIfNeeded()
    }
    
    private func updateCellViewConstraints() {
        
        NSLayoutConstraint.deactivate(cellViewConstraints)
        cellViewConstraints = [
            chevronImage.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -10),
            chevronImage.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImage.leadingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -15)
        ]
        NSLayoutConstraint.activate(cellViewConstraints)
        
        layoutIfNeeded()
    }
    
    private func setup() {
        
        contentView.backgroundColor = .systemGray6
        
        
        contentView.addSubview(cellView)
        
        cellView.addSubview(titleLabel)
        cellView.addSubview(chevronImage)
        
        
    }

}
