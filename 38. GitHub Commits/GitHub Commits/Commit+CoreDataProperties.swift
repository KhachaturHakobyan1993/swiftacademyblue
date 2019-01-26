//
//  Commit+CoreDataProperties.swift
//  GitHub Commits
//
//  Created by Khachatur Hakobyan on 1/26/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date
    @NSManaged public var sha: String
    @NSManaged public var message: String
    @NSManaged public var url: String
    @NSManaged public var author: Author

}
