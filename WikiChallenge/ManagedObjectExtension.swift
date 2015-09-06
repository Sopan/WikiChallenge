//
//  ManagedObjectExtension.swift
//  WikiChallenge
//
//  Created by Sopan Sharma on 9/3/15.
//  Copyright © 2015 Sopan Sharma. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func toDict() -> Dictionary<String, AnyObject>! {
        
        let attributes = self.entity.attributesByName.keys
        let relationships = self.entity.relationshipsByName.keys
        var dict: [String: AnyObject] = [String: AnyObject]()
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        for attribute in attributes {
            let propertyValue: NSAttributeDescription = self.entity.propertiesByName[attribute]! as! NSAttributeDescription
            if propertyValue.attributeValueClassName != nil && propertyValue.attributeValueClassName == "NSDate" {
                let value: AnyObject? = self.valueForKey(attribute )
                if value != nil {
                    dict[attribute] = dateFormater.stringFromDate(value as! NSDate)
                } else {
                    dict[attribute] = ""
                }
                
            } else {
                let value: AnyObject? = self.valueForKey(attribute)
                dict[attribute ] = value
            }
        }
        
        for attribute in relationships {
            let relationship: NSManagedObject = self.valueForKey(attribute) as! NSManagedObject
            let value = relationship.valueForKey("newFilter") as! NSSet
            dict[attribute] = value
        }
        
        return dict
    }
}