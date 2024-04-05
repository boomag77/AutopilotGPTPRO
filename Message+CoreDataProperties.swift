

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: Date
    @NSManaged public var sender: String
    @NSManaged public var text: String
    @NSManaged public var session: Session

}

extension Message : Identifiable {

}
