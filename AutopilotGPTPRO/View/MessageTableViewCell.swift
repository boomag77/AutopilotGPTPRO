

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    private var text: String? {
        didSet {
            messageTextView.text = text
            layoutIfNeeded()
        }
    }
    
    private var sender: MessageSender? {
        didSet {
            if sender == .user {
                bulletPointView.tintColor = .red.withAlphaComponent(0.7)
                messageTextView.textColor = UIColor.gray.withAlphaComponent(0.85)
            } else {
                bulletPointView.tintColor = .green.withAlphaComponent(0.7)
            }
        }
    }
    
    
    
    private lazy var bulletPointView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "circle.fill")
        //view.tintColor = .green.withAlphaComponent(0.6)
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .black
        textView.textColor = .white.withAlphaComponent(0.85)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        contentView.backgroundColor = .black
        contentView.addSubview(bulletPointView)
        contentView.addSubview(messageTextView)
        
        NSLayoutConstraint.activate([
            bulletPointView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            bulletPointView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            bulletPointView.widthAnchor.constraint(equalToConstant: 20),
            bulletPointView.heightAnchor.constraint(equalToConstant: 20),
            
            messageTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            //messageTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            messageTextView.leadingAnchor.constraint(equalTo: bulletPointView.trailingAnchor, constant: 5),
            messageTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            messageTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func setText(text: String) {
        self.text = text
    }
    
    func setSender(sender: MessageSender) {
        self.sender = sender
    }

}
