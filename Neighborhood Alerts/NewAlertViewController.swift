//
//  NewAlertViewController.swift
//  Neighborhood Alerts
//
//  Created by Amit Joshi on 6/21/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import LocationPickerViewController

class NewAlertViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    let locationManager = CLLocationManager()
    let locationPickerSegueIdentifier = "LocationPickerSegue"
    let unwindToCreateNewAlertsSegueIdentifier = "UnwindToCreateNewAlertsSegue"
    
    var alertCategory: String?
    var pickedLocation: GeoPoint?
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alertDisplayNameField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionText.delegate = self
        scrollView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        categoryLabel.text = alertCategory ?? ""
        
        descriptionText.layer.borderColor = UIColor.lightGray.cgColor
        descriptionText.layer.borderWidth = 1.0
        descriptionText.layer.cornerRadius = 8
        
        // Dark mode
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        var context = appDelegate.persistentContainer.viewContext
//        if CoreDataHandler.darkMode(context: &context) {
//            overrideUserInterfaceStyle = .dark
//        } else {
//           overrideUserInterfaceStyle = .light
//       }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
    
    // MARK: - Location handlers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == locationPickerSegueIdentifier,
            let destination = segue.destination as? LocationPicker {
            destination.isAllowArbitraryLocation = true
            destination.pickCompletion = {
                (pickedLocationItem) in
                // Once the location has been picked, grab the coordinates
                let coordinates = pickedLocationItem.coordinate
                if let coordinates = coordinates {
                    self.pickedLocation = GeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    print("Location has been picked")
                }
            }
            // adding cancel and done buttons
            destination.addBarButtons()
        }
    }
    
    
    @IBAction func selectLocation(_ sender: Any) {
        self.performSegue(withIdentifier: locationPickerSegueIdentifier, sender: self)
    }
    
    
    // MARK: - Image handlers
    
    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addImageButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "",
            message: "Choose option",
            preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: {
            (action) in self.takePicture()
        }))
        controller.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            (action) in self.openPhotoLibrary()
        }))
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Keyboard dismissal
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // hide keyboard when pressing the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.scrollView.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - Segue unwinding
    @IBAction func unwindToNewAlertDetails(segue: UIStoryboardSegue) {}
    
    // MARK: - Save alert
    @IBAction func publishAlert(_ sender: Any) {
        // establish a connection to the Firestore DB
        let db = Firestore.firestore()
        
        // make sure an alert category exists
        guard let alertCategory = self.alertCategory else {
            return
        }
        
        // make sure this alert has a name
        let alertDisplayName = alertDisplayNameField.text
        if alertDisplayName == nil || alertDisplayName! == "" {
            let alertController = UIAlertController(
                title: "Alert name not provided",
                message: "Please give a name for this alert.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        // make sure we are logged in
        guard let emailAddress = Auth.auth().currentUser?.email else {
            return
        }
        
        // get this user's name
        let userDocRef = db.collection("users").document(emailAddress)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                
                let authorName = data["fullName"] as? String
                
                // check if location was selected
                guard let location = self.pickedLocation else {
                    let alertController = UIAlertController(
                        title: "Location not picked",
                        message: "Please pick a location for this alert.",
                        preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                // collect our alert data
                var newAlertData: [String: Any] = [
                    "authorEmail": emailAddress,
                    "authorName": authorName!,
                    "category": alertCategory,
                    "created": Timestamp(),
                    "description": self.descriptionText.text!,
                    "displayName": alertDisplayName,
                    "location": location,
                    "upvotes": 0,
                    "resolved": false
                ]
                
                // create a UUID for our new location
                let uuid = UUID().uuidString.lowercased()
                
                // upload image, if it exists
                if let image = self.imageView.image {
                    // compress this image
                    let compressedImage = image.jpegData(compressionQuality: 0.025)
                    // if this image exists, set the path
                    newAlertData["image"] = "\(uuid).png"
                    // let's upload this image
                    if let uploadData = UIImage(data: compressedImage!)!.pngData() {
                        let storageRef = Storage.storage().reference().child("\(uuid).png")
                        storageRef.putData(uploadData, metadata: nil) {
                            (metadata, error) in
                            // honestly, not much to do
                            // we already know where it's going to be uploaded
                            // can let things proceed asynchronously
                        }
                    }
                }
                
                // publish to Firestore
                let alertDocRef = db.collection("alerts").document(uuid)
                alertDocRef.setData(newAlertData) {
                    err in
                    let alertController = UIAlertController(
                        title: "Alert published!",
                        message: "Your alert has been published.",
                        preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: {
                            _ in
                            // dismiss to new alert table view
                            self.performSegue(withIdentifier: self.unwindToCreateNewAlertsSegueIdentifier, sender: self)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}
