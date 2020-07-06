//
//  ChangePasswordViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/28/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var resetCodeField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    
    let unwindToSettingsSegueIdentifier = "UnwindToSettings"
    
    var emailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        // populate email address on settings VC
        if let user = user {
            let email = user.email
            self.emailAddress = email
            if email != nil {
                Auth.auth().sendPasswordReset(withEmail: email!) {
                    err in
                    if err != nil {
                        print(err!)
                    }
                }
            }
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        Auth.auth().confirmPasswordReset(withCode: resetCodeField.text!, newPassword: newPasswordField.text!) {
            err in
            if let err = err {
                // unsuccessful reset
                let alertController = UIAlertController(
                    title: "Password change failed",
                    message: "Your reset code may be invalid or your new password may not be strong enough. Please try again.",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil))
                self.present(alertController, animated: true, completion: nil)
                print(err)
            } else {
                // successful reset
                let alertController = UIAlertController(
                    title: "Password change succeeded",
                    message: "Your password has been successfully changed.",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (_) in
                        self.performSegue(withIdentifier: self.unwindToSettingsSegueIdentifier, sender: self)
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
