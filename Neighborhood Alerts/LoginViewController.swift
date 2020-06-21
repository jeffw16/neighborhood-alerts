//
//  LoginViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let loginSegueIdentifier = "LoginSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Attempt to log in with Firebase
    @IBAction func loginAction(_ sender: Any) {
        let emailAddress: String = emailAddressField!.text!
        let password: String = passwordField!.text!
        
        Auth.auth().signIn(withEmail: emailAddress, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if error != nil || Auth.auth().currentUser == nil {
                // error logging in
                // show alert
                let alertController = UIAlertController(
                    title: "Login failed",
                    message: "The email address and password combination doesn't seem to be correct. Please try again.",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil))
                self!.present(alertController, animated: true, completion: nil)
            } else {
                // successful login, proceed to log in
                self!.performSegue(withIdentifier: self!.loginSegueIdentifier, sender: self!)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == loginSegueIdentifier,
            let destination = segue.destination as? TabViewController {
            // pass login VC to tab VC so it can come back during logout
            destination.origin = self
        }
    }
    
    // move from email address to password
    // source: https://stackoverflow.com/questions/31766896/switching-between-text-fields-on-pressing-return-key-in-swift
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       // Try to find next responder
       if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
          nextField.becomeFirstResponder()
       } else {
          // Not found, so remove keyboard.
          textField.resignFirstResponder()
       }
       // Do not add a line break
       return false
    }
    
    // hide keyboard when pressing the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
