//
//  TabViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    
    var origin: UIViewController!
    // cannot call it tabBar because there's a strong ptr in the superclass called tabBar
    @IBOutlet weak var weakTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        darkMode()
    }
    
    func darkMode() {
        // Dark mode
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var context = appDelegate.persistentContainer.viewContext
        if CoreDataHandler.darkMode(context: &context) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    

}
