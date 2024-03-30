
import Foundation

enum MessageSender: Hashable {
    case user
    case server
}

struct InstructionModel {
    var name: String
    var text: String
}

struct SessionModel: Equatable, Hashable {
    var date: Date
    var messages: Set<MessageModel>
    var tokensUsed: Int?
}

struct MessageModel: Hashable {
    
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.date == rhs.date &&
                lhs.sender == rhs.sender &&
                lhs.text == rhs.text &&
                lhs.cost == rhs.cost &&
                lhs.session == rhs.session
    }
    
    var date: Date
    var sender: MessageSender
    var text: String
    var cost: Int
    var session: SessionModel
}
