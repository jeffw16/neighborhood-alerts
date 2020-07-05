//
//  DetailedAlertViewController.swift
//  Neighborhood Alerts
//
//  Created by Amit Joshi on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

protocol UpdateUpvoteDelegate {
    func updateUpvote(_ newCount: Int)
}

protocol ResolveAlertDelegate {
    func resolveAlert()
}

class DetailedAlertViewController: UIViewController {
    
    var alertTitle: String?
    var alertDescription: String?
    var alertImageUrl: String?
    var alertAuthorName: String?
    var alertCategory: String?
    var alertUpvotes: Int?
    var alertId: String?
    
    var originVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var upvotesLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        titleLabel.text = alertTitle ?? ""
        authorLabel.text = "Posted by " + (alertAuthorName ?? "")
        descriptionLabel.text = alertDescription ?? ""
        categoryLabel.text = alertCategory ?? ""
        upvotesLabel.text = "\(alertUpvotes ?? 0)"
        
        if alertImageUrl != nil {
            // download the image
            let imageRef = Storage.storage().reference().child(alertImageUrl!)
            
            imageRef.getData(maxSize: 30 * 1024 * 1024) {
                (data, error) in
                
                if error == nil {
                    // got the image, set it
                    self.imageView.image = UIImage(data: data!)
                } else {
                    print(error!)
                }
            }
        }
    }
    

    @IBAction func thanksButton(_ sender: Any) {
        alertUpvotes! += 1
        updateUpvotes()
    }
    
    @IBAction func fakeNewsButton(_ sender: Any) {
        alertUpvotes! -= 1
        updateUpvotes()
    }
    
    @IBAction func markResolved(_ sender: Any) {
        (originVC as? ResolveAlertDelegate)?.resolveAlert()
        
        let db = Firestore.firestore()
        
        let updateData: [String: Any] = [
            "resolved": true
        ]
        
        let alertDocRef = db.collection("alerts").document(alertId!)
        alertDocRef.setData(updateData, merge: true) {
            err in
            // updated
        }
    }
    
    func updateUpvotes() {
        updateUpvotesLocally()
        updateUpvotesToDb()
    }
    
    func updateUpvotesLocally() {
        if let alertUpvotes = self.alertUpvotes {
            self.upvotesLabel.text = "\(alertUpvotes)"
            (originVC as? UpdateUpvoteDelegate)?.updateUpvote(alertUpvotes)
        }
    }
    
    func updateUpvotesToDb() {
        let db = Firestore.firestore()
        
        let updateData: [String: Any] = [
            "upvotes": alertUpvotes!
        ]
        
        let alertDocRef = db.collection("alerts").document(alertId!)
        alertDocRef.setData(updateData, merge: true) {
            err in
            // updated
        }
    }
}
