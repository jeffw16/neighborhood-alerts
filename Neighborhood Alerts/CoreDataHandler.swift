//
//  CoreDataHandler.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 7/2/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

let userLocalDataName: String = "UserLocalData"

class CoreDataHandler {
    fileprivate static func fetchUserLocalDataNSManagedObject(_ email: String, context: inout NSManagedObjectContext) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: userLocalDataName)
        
        var fetchedResults: [NSManagedObject]? = nil
        
        let predicate = NSPredicate(format: "emailAddress CONTAINS[c] '\(email)'")
        request.predicate = predicate
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        guard let nsManagedObjects = fetchedResults else { return nil }
        
        if nsManagedObjects.count != 1 {
            return nil
        }
        
        return nsManagedObjects[0]
    }
    
    /*static func fetchUserLocalData(email: String, context: inout NSManagedObjectContext, key: String) -> [String: Any?] {
        let fetchedResult = fetchUserLocalDataNSManagedObject(email, context: &context)
        
        guard let resultData = fetchedResult else {
            return [:]
        }
        
        let result = ["locationBasedAlerts": resultData.value(forKey: "locationBasedAlerts")]
        
        return result
    }*/
    
    static func storeUserLocalData(email: String, context: inout NSManagedObjectContext, key: String, value: Any) {
        print ("trying to store key: \(key)")
        var nsManagedObject = CoreDataHandler.fetchUserLocalDataNSManagedObject(email, context: &context)
        
        if nsManagedObject == nil {
            // create a new object
            print ("it was nil")
            nsManagedObject = NSEntityDescription.insertNewObject(forEntityName: userLocalDataName, into: context)
            nsManagedObject!.setValue(email, forKey: "emailAddress")
            nsManagedObject!.setValue(value, forKey: key)
                   
            context.insert(nsManagedObject!)
        }
        else{
            print ("not nil")
            nsManagedObject!.setValue(value, forKey: key)
        }
        
       
        
        do {
            try context.save()
        } catch {
            print ("ah sh*t an error")
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}
