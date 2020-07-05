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
    @IBOutlet weak var pushNotifsSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
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
                        let data = document.data()!
                        
                        self.fullNameLabel!.text = data["fullName"] as? String
                        self.homeAddressLabel!.text = data["homeAddress"] as? String
                    }
                }
                // retrieve user local data from Core Data
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                var context = appDelegate.persistentContainer.viewContext
                
                let locationBasedAlertsVal = CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "locationBasedAlerts")
                
                if let val = locationBasedAlertsVal as? Bool {
                    switch val {
                    case true:
                        alertsSourceSegCtrl.selectedSegmentIndex = 0
                    case false:
                        alertsSourceSegCtrl.selectedSegmentIndex = 1
                    }
                }
                
                let alertsRadiusVal = CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "alertsRadius")
                
                if let val = alertsRadiusVal as? Int {
                    switch val {
                    case 1:
                        alertsRadiusSegCtrl.selectedSegmentIndex = 0
                    case 2:
                        alertsRadiusSegCtrl.selectedSegmentIndex = 1
                    case 10:
                        alertsRadiusSegCtrl.selectedSegmentIndex = 2
                    case 25:
                        alertsRadiusSegCtrl.selectedSegmentIndex = 3
                    case 50:
                        alertsRadiusSegCtrl.selectedSegmentIndex = 4
                    default:
                        alertsRadiusSegCtrl.selectedSegmentIndex = 3
                    }
                }
            } else {
                emailAddressLabel!.text = "Email address: Unknown"
            }
        }
    }
    
    func setSettings() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = appDelegate.persistentContainer.viewContext
        let user = Auth.auth().currentUser
        if let email = user?.email {
            CoreDataHandler.storeUserLocalData(email: email, context: &context, key: "pushNotifs", value: pushNotifsSwitch.isOn)
            
            CoreDataHandler.storeUserLocalData(email: email, context: &context, key: "darkMode", value: darkModeSwitch.isOn)
            
            CoreDataHandler.storeUserLocalData(email: email, context: &context, key: "locationBasedAlerts", value: alertsSourceSegCtrl.selectedSegmentIndex == 0)
            
            CoreDataHandler.storeUserLocalData(email: email, context: &context, key: "alertsRadius", value: radii[alertsRadiusSegCtrl.selectedSegmentIndex])
        }
    }
    
    @IBAction func setPushNotifs(_ sender: Any) {
        setSettings()
    }
    
    @IBAction func setDarkMode(_ sender: Any) {
        setSettings()
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
