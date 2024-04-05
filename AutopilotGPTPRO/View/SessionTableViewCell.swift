
import UIKit

class SessionTableViewCell: UITableViewCell {
    
    private var title: String? {
        didSet {
            titleLabel.text = title
            layoutIfNeeded()
        }
    }
    private var date: String? {
        didSet {
            dateLabel.text = date
            layoutIfNeeded()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    
    private func setup() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            titleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -10)
        ])
        
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func setDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        self.date = dateFormatter.string(from: date)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
