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

class SettingsViewController: UIViewController, UIScrollViewDelegate, UITabBarControllerDelegate {
    
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
    let radiiToIndex = [1: 0,
                        2: 1,
                        10: 2,
                        25: 3,
                        50: 4]
    
    override func viewDidLoad() {
        self.scrollView.delegate = self
        (self.parent?.parent as! UITabBarController).delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            } else {
                emailAddressLabel!.text = "Email address: Unknown"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // get user info
        let user = Auth.auth().currentUser
        // populate email address on settings VC
        if let email = user?.email {
            // retrieve user local data from Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            var context = appDelegate.persistentContainer.viewContext
            
            if CoreDataHandler.darkMode(context: &context) {
                darkModeSwitch.isOn = true
            } else {
                darkModeSwitch.isOn = false
            }
            
            let pushNotifsVal = CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "pushNotifs")
            
            if let val = pushNotifsVal {
                pushNotifsSwitch.isOn = val as! Bool
            }
            
            let locationBasedAlertsVal = CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "locationBasedAlerts")
            
            if let val = locationBasedAlertsVal as? Bool {
                alertsSourceSegCtrl.selectedSegmentIndex = val ? 0 : 1
            }
            
            let alertsRadiusVal = CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "alertsRadius")
            
            if let val = alertsRadiusVal as? Int {
//                    alertsRadiusSegCtrl.selectedSegmentIndex = radiiToIndex[val] ?? 3
                
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
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // run the dark mode check again when the tab bar is changed
        (tabBarController as! TabViewController).darkMode()
    }
    
    @IBAction func helpAlertsSource(_ sender: Any) {
        let alertController = UIAlertController(
            title: "See alerts from",
            message: "In the alerts list, you can choose to see alerts from your device's current geographical location or the home address associated with your account. This setting only applies to the alerts list, not the alerts map.",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func helpAlertsRadius(_ sender: Any) {
        let alertController = UIAlertController(
            title: "See alerts within",
            message: "Change the range of alerts you'd like to view. This setting only applies to the alerts list, not the alerts map.",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
//        setSettings()
    }
    
    @IBAction func setDarkMode(_ sender: Any) {
//        setSettings()
        let alertController = UIAlertController(
            title: "Dark mode",
            message: "Changes take effect after you press save and leave the settings pane.",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func setAlertSource(_ sender: Any) {
//        setSettings()
    }
    
    @IBAction func setAlertRadius(_ sender: Any) {
//        setSettings()
    }
    
    @IBAction func saveSettings(_ sender: Any) {
        setSettings()
        let alertController = UIAlertController(
            title: "Settings saved",
            message: "Your settings have been saved. Changes will be effective when you leave the settings pane.",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func clearSettings(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = appDelegate.persistentContainer.viewContext
        let user = Auth.auth().currentUser
        if let email = user?.email {
            let alertController = UIAlertController(
                title: "Clear settings",
                message: "Are you sure you want to reset your settings? This cannot be undone. Changes take full effect after closing and reopening the app.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "Clear settings",
                style: .destructive,
                handler: {
                    _ in
                    CoreDataHandler.fetchUserLocalData(email: email, context: &context, key: "", deleteAll: true)
            }))
            alertController.addAction(UIAlertAction(
                title: "Never mind",
                style: .cancel,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
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
