//
//  LoginViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    let loginSegueIdentifier = "LoginSegueIdentifier"
    let createAccountBeginSegueIdentifier = "CreateAccountBeginSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // check if already logged in
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                self.performSegue(withIdentifier: self.loginSegueIdentifier, sender: self)
            }
        }
        // set up text field delegates to allow for pressing return
        // to jump to the next text field, as appropriate!
        emailAddressField.delegate = self
        passwordField.delegate = self
    }
    
    // Attempt to log in with Firebase
    @IBAction func loginAction(_ sender: Any) {
        login()
    }
    
    func login() {
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
        } else if segue.identifier == createAccountBeginSegueIdentifier,
            let destination = segue.destination as? CreateAccountViewController {
            // pass login VC to create account VC so it can reference login segue
            destination.loginVC = self
        }
    }
    
    // used by the ResetPasswordViewController
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    // when return pressed and currently editing email address:
    // move from email address to password
    // when return pressed and currently editing password:
    // attempt log in
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == emailAddressField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            login()
        }
        
        return true
    }
    
    // hide keyboard when pressing the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
