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

let cachedImageName: String = "CachedImage"

class CoreDataHandler {
    fileprivate static func fetchUserLocalDataNSManagedObject(_ email: String, context: inout NSManagedObjectContext, deleteExtras: Bool, deleteAll: Bool = false) -> NSManagedObject? {
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
        
        if nsManagedObjects.count != 1 || deleteAll {
            if deleteExtras || deleteAll {
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
    
    static func fetchUserLocalData(email: String, context: inout NSManagedObjectContext, key: String, deleteAll: Bool = false) -> Any? {
        let nsManagedObjectOptional = fetchUserLocalDataNSManagedObject(email, context: &context, deleteExtras: true, deleteAll: deleteAll)
        
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
    
    // dark mode Core Data
    
    static func darkMode(context: inout NSManagedObjectContext) -> Bool {
        let user = Auth.auth().currentUser
        guard let email = user?.email else { return false }
        
        let darkMode: Bool = (CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "darkMode") ?? false) as! Bool
        
        return darkMode
    }

    // Image core data
    
    fileprivate static func fetchCachedImageNSManagedObject(_ name: String, context: inout NSManagedObjectContext, deleteExtras: Bool, deleteAll: Bool = false) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: cachedImageName)
        
        var fetchedResults: [NSManagedObject]? = nil
        
        let predicate = NSPredicate(format: "name CONTAINS[c] '\(name)'")
        request.predicate = predicate
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        guard let nsManagedObjects = fetchedResults else { return nil }
        
        if nsManagedObjects.count != 1 || deleteAll {
            if deleteExtras || deleteAll {
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
    
    static func fetchCachedImageData(name: String, context: inout NSManagedObjectContext, deleteAll: Bool = false) -> Any? {
        let nsManagedObjectOptional = fetchCachedImageNSManagedObject(name, context: &context, deleteExtras: true, deleteAll: deleteAll)
        
        if let result = nsManagedObjectOptional {
            return result.value(forKey: "data")
        }
        
        return nil
    }
    
    static func storeCachedImageData(name: String, data: Data, context: inout NSManagedObjectContext) {
        var nsManagedObject = CoreDataHandler.fetchCachedImageNSManagedObject(name, context: &context, deleteExtras: false)
        
        if nsManagedObject == nil {
            // create a new object
            nsManagedObject = NSEntityDescription.insertNewObject(forEntityName: cachedImageName, into: context)
            nsManagedObject!.setValue(data, forKey: "data")
            nsManagedObject!.setValue(name, forKey: "name")
            context.insert(nsManagedObject!)
        } else {
            // modify the key for the existing object
            nsManagedObject!.setValue(data, forKey: "data")
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
