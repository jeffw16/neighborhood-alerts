//
//  ChangeAddressViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/28/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChangeAddressViewController: UIViewController {
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var newAddressField: UITextField!
    
    let unwindToSettingsSegueIdentifier = "UnwindToSettings"
    
    var user: User?
    
    override func viewWillAppear(_ animated: Bool) {
        // get user info
        user = Auth.auth().currentUser
        // populate email address on settings VC
        if let user = user {
            let emailOpt = user.email
            if let email = emailOpt {
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(email)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()!
                        self.currentAddressLabel!.text = data["homeAddress"] as? String
                    }
                }
            } else {
                currentAddressLabel!.text = "Unknown - please log out, log back in, and try again."
            }
        }
        
//        // Dark mode
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        var context = appDelegate.persistentContainer.viewContext
//        if CoreDataHandler.darkMode(context: &context) {
//            overrideUserInterfaceStyle = .dark
//        } else {
//            overrideUserInterfaceStyle = .light
//        }
    }
    
    @IBAction func changeAddress(_ sender: Any) {
        if let user = user {
            let emailOpt = user.email
            if let email = emailOpt {
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(email)
                docRef.setData(["homeAddress": newAddressField.text!], merge: true) {
                    err in
                    let alertController = UIAlertController(
                        title: "Address changed",
                        message: "Your address has been changed!",
                        preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: {
                            _ in
                            self.performSegue(withIdentifier: self.unwindToSettingsSegueIdentifier, sender: self)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

}
