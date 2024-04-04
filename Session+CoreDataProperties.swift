//
//  Session+CoreDataProperties.swift
//  AutopilotGPTPRO
//
//  Created by Sergey on 4/3/24.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var date: Date?
    @NSManaged public var tokensUsed: Int64
    @NSManaged public var id: Int64
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension Session {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension Session : Identifiable {

}
