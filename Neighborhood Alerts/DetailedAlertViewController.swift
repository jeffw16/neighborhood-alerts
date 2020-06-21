//
//  DetailedAlertViewController.swift
//  Neighborhood Alerts
//
//  Created by Amit Joshi on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit

class DetailedAlertViewController: UIViewController {
    
    var alertTitle: String?
    var alertDescription: String?
    var alertImage: UIImage?
    var alertAuthor: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        titleLabel.text = alertTitle! ?? ""
        
        authorLabel.text = "Posted by " + alertAuthor! ?? ""
        
        descriptionLabel.text = alertDescription! ?? ""
        
        if alertImage != nil {
            imageView.image = alertImage
        }
        
        
        
        
        
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
