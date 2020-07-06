//
//  CoreDataHandler.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 7/2/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import CoreData

let userLocalDataName: String = "UserLocalData"

class CoreDataHandler {
    fileprivate static func fetchUserLocalDataNSManagedObject(_ email: String, context: inout NSManagedObjectContext, deleteExtras: Bool) -> NSManagedObject? {
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
            if deleteExtras {
                for obj in nsManagedObjects {
                    context.delete(obj)
                }
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
            return nil
        }
        
        return nsManagedObjects[0]
    }
    
    static func fetchUserLocalData(email: String, context: inout NSManagedObjectContext, key: String) -> Any? {
        let nsManagedObjectOptional = fetchUserLocalDataNSManagedObject(email, context: &context, deleteExtras: true)
        
        if let result = nsManagedObjectOptional {
            return result.value(forKey: key)
        }
        
        return nil
    }
    
    static func storeUserLocalData(email: String, context: inout NSManagedObjectContext, key: String, value: Any) {
        var nsManagedObject = CoreDataHandler.fetchUserLocalDataNSManagedObject(email, context: &context, deleteExtras: false)
        
        if nsManagedObject == nil {
            // create a new object
            nsManagedObject = NSEntityDescription.insertNewObject(forEntityName: userLocalDataName, into: context)
            nsManagedObject!.setValue(email, forKey: "emailAddress")
            nsManagedObject!.setValue(value, forKey: key)
            context.insert(nsManagedObject!)
        } else {
            // modify the key for the existing object
            nsManagedObject!.setValue(value, forKey: key)
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    static func darkMode(context: inout NSManagedObjectContext) -> Bool {
        let user = Auth.auth().currentUser
        guard let email = user?.email else { return false }
        
        let darkMode: Bool = (CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "darkMode") ?? false) as! Bool
        
        return darkMode
    }

}
