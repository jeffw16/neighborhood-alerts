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

class SettingsViewController: UIViewController {
    
    let logoutSegueIdentifier: String = "LogoutSegueIdentifier"
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get user info
        let user = Auth.auth().currentUser
        // populate email address on settings VC
        if let user = user {
            let email = user.email
            if email != nil {
                emailAddressLabel!.text = "\(email!)"
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(email!)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
//                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                        print("Document data: \(dataDescription)")
                        self.fullNameLabel!.text = document.data()!["fullName"] as? String
                    }
                }
            } else {
                emailAddressLabel!.text = "Email address: Unknown"
            }
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
