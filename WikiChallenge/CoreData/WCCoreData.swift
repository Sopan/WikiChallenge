//
//  WCCoreData.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class WCCoreData {
    
    var managedObjectContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    
    /* Retrieve all existing Filters from Core Data */
    func fetchFilters() -> [Filter] {
        var filterList = [Filter]()
        let fetchRequest = NSFetchRequest(entityName: "Filter")
        let sortDescriptor = NSSortDescriptor(key: "searchString", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Filter]
            filterList = fetchResults!
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
        
        return filterList
    }
    
    
    /* Retrieves all existing Wiki records from Core Data */
    func fetchWiki(title: String) -> [Wiki] {
        var wikiList = [Wiki]()
        let fetchRequest = NSFetchRequest(entityName: "Wiki")
        let sortDescriptor = NSSortDescriptor(key: "searchResults.searchString", ascending: true)
        let predicate = NSPredicate(format: "searchResults.searchString == %@", title)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Wiki]
            wikiList = fetchResults!
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
        
        return wikiList
    }
    
    
    /* Creates a new Filter entity */
    func addNewFilter(title: String) -> Filter {
        return Filter.createInManagedObjectContext(self.managedObjectContext, title: title)
    }
    
    
    /* Creates a new Wiki entity */
    func addNewWikiEntry(searchTitle: String, timestamp: String, filterData: Filter) -> Wiki {
        return Wiki.createInManagedObjectContext(self.managedObjectContext, title: searchTitle, date: timestamp, searchData: filterData)
    }
    
    
    /* Saves data to Core Data */
    func save() {
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    
    /* Check for duplicate data and if there isn't
       only then save it */
    func addWikiData(data: NSDictionary, filter: Filter) {
        guard (data["title"] != nil && data["timestamp"] != nil) else {
            return
        }
        
        let request = NSFetchRequest(entityName: "Wiki")
        request.predicate = NSPredicate(format: "title == %@", data["title"] as! String)
        var error: NSError? = nil
        let resultsCount = self.managedObjectContext.countForFetchRequest(request, error: &error)
        guard resultsCount == 0 else {
            return
        }
        
        self.addNewWikiEntry(data["title"] as! String, timestamp: data["timestamp"] as! String, filterData: filter)
    }
}
