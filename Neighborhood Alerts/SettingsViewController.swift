//
//  SettingsViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData

class SettingsViewController: UIViewController, UIScrollViewDelegate {
    
    let logoutSegueIdentifier: String = "LogoutSegueIdentifier"
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var homeAddressLabel: UILabel!
    @IBOutlet weak var alertsSourceSegCtrl: UISegmentedControl!
    @IBOutlet weak var alertsRadiusSegCtrl: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    let radii = [1, 2, 10, 25, 50]
    
    override func viewDidLoad() {
        self.scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get user info
        let user = Auth.auth().currentUser
        // populate email address on settings VC
        if let user = user {
            let email = user.email
            if let email = email {
                emailAddressLabel!.text = "\(email)"
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(email)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
//                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                        print("Document data: \(dataDescription)")
                        let data = document.data()!
                        
                        self.fullNameLabel!.text = data["fullName"] as? String
                        self.homeAddressLabel!.text = data["homeAddress"] as? String
                    }
                }
                // retrieve user local data from Core Data
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLocalData")
                
                var fetchedResults: [NSManagedObject]? = nil
                
                let predicate = NSPredicate(format: "emailAddress CONTAINS[c] '\(email)'")
                request.predicate = predicate
                
                do {
                    try fetchedResults = context.fetch(request) as? [NSManagedObject]
                } catch {
                    let nsError = error as NSError
                    NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                
                if let nsManagedObjects = fetchedResults {
                    if nsManagedObjects.count != 1 {
                        for obj in nsManagedObjects {
                            context.delete(obj)
                        }
                        do {
                            try context.save()
                        } catch {
                            let nsError = error as NSError
                            NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    } else {

                        let nsManagedObject = nsManagedObjects[0]
                        
                        let locationBasedAlertsVal = nsManagedObject.value(forKey: "locationBasedAlerts")
                        
                        if let locationBasedAlerts = locationBasedAlertsVal {
                            if locationBasedAlerts as! Bool {
                                alertsSourceSegCtrl.selectedSegmentIndex = 0
                                print("Set to 0")
                            } else {
                                alertsSourceSegCtrl.selectedSegmentIndex = 1
                                print("Set to 1")
                            }
                        }
                        
                        
                        let alertsRadiusVal = nsManagedObject.value(forKey: "alertsRadius")
                        
                        if let alertsRadius = alertsRadiusVal{
                            if alertsRadius as! Int == 1 {
                                alertsRadiusSegCtrl.selectedSegmentIndex = 0
                            }
                            else if alertsRadius as! Int == 2 {
                                alertsRadiusSegCtrl.selectedSegmentIndex = 1
                            }
                            else if alertsRadius as! Int == 10 {
                                alertsRadiusSegCtrl.selectedSegmentIndex = 2
                            }
                            else if alertsRadius as! Int == 25 {
                                alertsRadiusSegCtrl.selectedSegmentIndex = 3
                            }
                            else if alertsRadius as! Int == 50 {
                                alertsRadiusSegCtrl.selectedSegmentIndex = 4
                            }
                        }
                    }
                }
                
                /*
                let userLocalData = CoreDataHandler.fetchUserLocalData(email: email, context: &context)
                if userLocalData.count != 0 {
                    // don't use the defaults if we have Core Data stored that says otherwise
                    alertsSourceSegCtrl.selectedSegmentIndex = (userLocalData["locationBasedAlerts"] != nil && userLocalData["locationBasedAlerts"] as! Bool == true) ? 0 : 1
                    print("Location based alerts data: \(String(describing: userLocalData["locationBasedAlerts"]))")
                } else {
                    print("Data does not exist")
                }
                 */
            } else {
                emailAddressLabel!.text = "Email address: Unknown"
            }
        }
    }
    
    func setSettings(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = appDelegate.persistentContainer.viewContext
        let user = Auth.auth().currentUser
        if let email = user?.email {
            CoreDataHandler.storeUserLocalData(email: email, context: &context, key: "locationBasedAlerts", value: alertsSourceSegCtrl.selectedSegmentIndex == 0)
            
            CoreDataHandler.storeUserLocalData(email: email, context: &context, key: "alertsRadius", value: radii[alertsRadiusSegCtrl.selectedSegmentIndex])
            
            /*let entity = NSEntityDescription.entity(forEntityName: "UserLocalData", in: context)!
            let nsManagedObject = NSManagedObject(entity: entity, insertInto: context)
            nsManagedObject.setValue(email, forKey: "emailAddress")
            nsManagedObject.setValue(alertsSourceSegCtrl.selectedSegmentIndex == 0, forKey: "locationBasedAlerts")
            nsManagedObject.setValue(alertsRadiusSegCtrl.selectedSegmentIndex, forKey: "alertsRadius")
            
//            context.insert(nsManagedObject)
            
            do {
                try context.save()
            } catch {
                print ("error")
                let nsError = error as NSError
                NSLog("Unresolved error \(nsError), \(nsError.userInfo)")
            }
 
 
            
            print("Set alert source to \(alertsSourceSegCtrl.selectedSegmentIndex)")
 
            */
            
            
        }
    }
    @IBAction func setAlertSource(_ sender: Any) {
        setSettings()
    }
    
    @IBAction func setAlertRadius(_ sender: Any) {
        setSettings()
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        // perform log out actions
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        // then segue to the login page
        performSegue(withIdentifier: logoutSegueIdentifier, sender: self)
    }
    
    // for ChangeAddressViewController
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {}

}
