//
//  CoreDataHelper.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/5/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import Foundation

import CoreData

func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
        try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    } catch let error as NSError {
        print("Error while adding persistentStore \(error), \(error.userInfo)")
    }
    
    let managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}