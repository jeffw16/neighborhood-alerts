//
//  ResetPasswordViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/28/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailAddressField: UITextField!
    
    let unwindToLoginSegueIdentifier = "UnwindToLogin"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func initiatePasswordReset(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailAddressField.text!) {
            err in
            if let err = err {
                // unsuccessful reset
                let alertController = UIAlertController(
                    title: "Error resetting password",
                    message: "Your email address may be invalid or this email address doesn't exist as an account. Please try again.",
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
                    title: "Password reset initiated",
                    message: "A password reset link will be sent to the email address specified once you click the Change Password button. Please follow the instructions sent in the email to proceed.",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (_) in
                        self.performSegue(withIdentifier: self.unwindToLoginSegueIdentifier, sender: self)
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

}
