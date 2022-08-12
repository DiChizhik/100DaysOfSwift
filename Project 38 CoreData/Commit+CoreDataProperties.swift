//
//  Commit+CoreDataProperties.swift
//  Project 38 CoreData
//
//  Created by Diana Chizhik on 14/07/2022.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var sha: String
    @NSManaged public var url: String
    @NSManaged public var message: String
    @NSManaged public var date: Date
    @NSManaged public var author: Author

}

extension Commit : Identifiable {

}
