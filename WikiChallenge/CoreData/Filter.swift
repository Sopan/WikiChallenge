//
//  Filter.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/3/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import Foundation
import CoreData

//@objc(Filter)

class Filter: NSManagedObject {

    @NSManaged var searchString: String?
    @NSManaged var newFilter: NSSet?
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String) -> Filter {
        let newGuide = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: moc) as! Filter
        newGuide.searchString = title
        
        return newGuide
    }

}
