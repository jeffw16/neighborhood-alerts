//
//  SettingsViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    let logoutSegueIdentifier: String = "LogoutSegueIdentifier"
    
    @IBOutlet weak var emailAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get user info
        let user = Auth.auth().currentUser
        // populate email address on settings VC
        if let user = user {
            let email = user.email
            emailAddressLabel!.text = "Email address: \(email ?? "Unknown")"
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

}
