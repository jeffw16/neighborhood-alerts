//
//  ListViewController.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 6/20/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var alertsList: [Alert] = []
    
    

    let detailedAlertSegueIdentifier = "DetailedAlertSegueIdentifier"
    
    let alertCellIdentifier: String = "AlertCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        var alert1 = Alert(id: "ae34f1134", displayName: "Fire on Fake Street", description: "Theres a fire bro what more do u want", category: "Fire", image: nil, latitude: CLLocationDegrees(39.127112), longitude: CLLocationDegrees(-77.533134), author: "Jeffrey Wang")
        
        alertsList.append(alert1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: alertCellIdentifier, for: indexPath)
        
        let rowNum = indexPath.row
        
        cell.textLabel?.text = alertsList[rowNum].displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailedAlertSegueIdentifier {
            let nextVC = segue.destination as! DetailedAlertViewController
            
            let alertIndex:Int = tableView.indexPathForSelectedRow?.row ?? 0
            
            nextVC.alertTitle = alertsList[alertIndex].displayName
            
            nextVC.alertDescription = alertsList[alertIndex].description
            
            nextVC.alertImage = alertsList[alertIndex].image
            
            nextVC.alertAuthor = alertsList[alertIndex].author
            
            
        }
    }



}

