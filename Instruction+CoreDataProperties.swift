//
//  Instruction+CoreDataProperties.swift
//  AutopilotGPTPRO
//
//  Created by Sergey on 3/28/24.
//
//

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
