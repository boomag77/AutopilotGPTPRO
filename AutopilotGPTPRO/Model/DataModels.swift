
import Foundation

enum MessageSender {
    case user
    case server
}

struct InstructionModel {
    var name: String
    var text: String
}

struct SessionModel {
    var date: Date
    var messages: [MessageModel]
    var tokensUsed: Int?
}

struct MessageModel {
    var date: Date
    var sender: MessageSender
    var text: String
}
