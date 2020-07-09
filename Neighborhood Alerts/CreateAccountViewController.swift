//
//  CreateAccountViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/21/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var homeAddressField: UITextField!
    
    var loginVC: UIViewController!
    
    let createAccountLoginSegueIdentifier: String = "CreateAccountLoginSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddressField.delegate = self
        passwordField.delegate = self
        phoneNumberField.delegate = self
        nameField.delegate = self
        homeAddressField.delegate = self
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        createAccount()
    }
    
    // actual actions to create the account
    func createAccount() {
        // check if anything is blank
        if emailAddressField.text == ""
            || passwordField.text == ""
            || phoneNumberField.text == ""
            || nameField.text == ""
            || homeAddressField.text == "" {
            let alertController = UIAlertController(
                title: "Account creation failed",
                message: "Please fill in all fields to create an account.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        // actually create the account on Firebase
        Auth.auth().createUser(withEmail: emailAddressField.text!, password: passwordField.text!) { authResult, error in
            if error != nil || Auth.auth().currentUser == nil {
                // error creating an account
                // show alert
                print("Error: \(error ?? "Something went wrong, we are working on it. Please come back later." as! Error)")
                let alertController = UIAlertController(
                    title: "Account creation failed",
                    message: "There seems to be a problem with creating this account. Perhaps this email already exists or your password is shorter than 6 characters. Please try again.",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                // successful login, proceed to log in
                let db = Firestore.firestore()
                db.collection("users").document(self.emailAddressField.text!).setData([
                    "fullName": self.nameField.text!,
                    "homeAddress": self.homeAddressField.text!,
                    "phoneNumber": self.phoneNumberField.text!
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document created successfully!")
                    }
                }
                self.performSegue(withIdentifier: self.createAccountLoginSegueIdentifier, sender: self)
            }
        }
    }
    
    // return press flow
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField {
        case emailAddressField:
            passwordField.becomeFirstResponder()
        case passwordField:
            phoneNumberField.becomeFirstResponder()
        case phoneNumberField:
            nameField.becomeFirstResponder()
        case nameField:
            homeAddressField.becomeFirstResponder()
        case homeAddressField:
            createAccount()
        default:
            break
        }
        
        return true
    }
    
    // hide keyboard when pressing the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
