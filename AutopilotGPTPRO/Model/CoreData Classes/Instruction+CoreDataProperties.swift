
import Foundation
import CoreData


extension Instruction {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Instruction> {
        return NSFetchRequest<Instruction>(entityName: "Instruction")
    }

    @NSManaged public var name: String
    @NSManaged public var text: String

}

extension Instruction : Identifiable {

}
