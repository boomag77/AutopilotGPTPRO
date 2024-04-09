
import UIKit

class SessionTableViewCell: UITableViewCell {
    
    private var padding: CGFloat = 2
    
    private var paddingConstraints: [NSLayoutConstraint] = []
    private var cellViewConstraints: [NSLayoutConstraint] = []
    
    private var title: String? {
        didSet {
            titleLabel.text = title
            updateCellViewConstraints()
            updatePaddingConstraints()
        }
    }
    private var date: String? {
        didSet {
            dateLabel.text = date
            updateCellViewConstraints()
            updatePaddingConstraints()
        }
    }
    
    private var sessionID: String? {
        didSet {
            idLabel.text = sessionID
            updateCellViewConstraints()
            updatePaddingConstraints()
        }
        
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .label.withAlphaComponent(0.85)
        label.contentMode = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .label.withAlphaComponent(0.85)
        label.contentMode = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .label.withAlphaComponent(0.85)
        label.contentMode = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private func setup() {
        
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(cellView)
        
        cellView.addSubview(titleLabel)
        cellView.addSubview(dateLabel)
        cellView.addSubview(idLabel)
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func setDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        self.date = dateFormatter.string(from: date)
    }
    
    func setIdNumber(id: Int) {
        self.sessionID = String(id)
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
            idLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -10),
            idLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: idLabel.trailingAnchor, constant: -10),
            
            titleLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(cellViewConstraints)
        
        layoutIfNeeded()
    }

}
