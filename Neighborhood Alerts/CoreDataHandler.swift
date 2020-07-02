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
    
    static func fetchUserLocalData(email: String) -> [String: Any?] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = appDelegate.persistentContainer.viewContext
        
        let fetchedResult = fetchUserLocalDataNSManagedObject(email, context: &context)
        
        guard let resultData = fetchedResult else {
            return [:]
        }
        
        let result = ["locationBasedAlerts": resultData.value(forKey: "locationBasedAlerts")]
        
        return result
    }
    
    static func storeUserLocalData(email: String, key: String, value: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = appDelegate.persistentContainer.viewContext
        
        var nsManagedObject = CoreDataHandler.fetchUserLocalDataNSManagedObject(email, context: &context)
        
        if nsManagedObject == nil {
            // create a new object
            nsManagedObject = NSEntityDescription.insertNewObject(forEntityName: userLocalDataName, into: context)
        }
            
        nsManagedObject!.setValue(value, forKey: key)
        
        context.refresh(nsManagedObject!, mergeChanges: true)
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
}
