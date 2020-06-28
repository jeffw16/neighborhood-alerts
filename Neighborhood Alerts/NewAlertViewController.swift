//
//  NewAlertViewController.swift
//  Neighborhood Alerts
//
//  Created by Amit Joshi on 6/21/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit

class NewAlertViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var alertCategory: String?
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        categoryLabel.text = alertCategory ?? ""
    }
    
    func takePicture(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func addImageButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "",
            message: "Choose option",
            preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: {
            (action) in takePicture()
        }))
        controller.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            (action) in openPhotoLibrary()
        }))
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func openCameraButtonPressed(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
