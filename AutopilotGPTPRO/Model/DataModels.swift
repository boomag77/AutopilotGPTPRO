
import Foundation

enum MessageSender: String, Hashable {
    case user = "user"
    case autopilot = "autopilot"
}

struct InstructionModel {
    var name: String
    var text: String
}

struct SessionModel: Equatable, Hashable {
    var id: Int
    var date: Date
    var position: String
    var messages: Set<MessageModel>?
    var tokensUsed: Int?
}

struct MessageModel: Hashable {
    
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.date == rhs.date &&
                lhs.sender == rhs.sender &&
                lhs.text == rhs.text
    }
    
    var date: Date
    var sender: MessageSender
    var text: String
}


enum Language {
    case english
    case spanish
    case french
    case russian
}
