//
//  Wiki.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/3/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import Foundation
import CoreData

//@objc(Wiki)

class Wiki: NSManagedObject {
    
    @NSManaged var timestamp: String?
    @NSManaged var title: String?
    @NSManaged var searchResults: Filter?

    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, date: String, searchData: Filter) -> Wiki {
        let newWiki = NSEntityDescription.insertNewObjectForEntityForName("Wiki", inManagedObjectContext: moc) as! Wiki
        
        newWiki.title = title
        newWiki.timestamp = date
        newWiki.searchResults = searchData
        
        return newWiki
    }

}
