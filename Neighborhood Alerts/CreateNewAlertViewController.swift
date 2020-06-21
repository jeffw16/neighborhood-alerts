//
//  CreateNewAlertViewController.swift
//  Neighborhood Alerts
//
//  Created by Amit Joshi on 6/21/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit

class CreateNewAlertViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    

    @IBOutlet weak var tableView: UITableView!
    
    var categoriesList: [String] = []
    
    let newAlertSegueIdentifier: String = "NewAlertSegueIdentifier"
    
    let categoryCellIdentifier: String = "CategoryCellIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoriesList.append("Fire")
        categoriesList.append("Bear Sighting")
        categoriesList.append("Burglary")
        categoriesList.append("Other")
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath)
         
         let rowNum = indexPath.row
         
         cell.textLabel?.text = categoriesList[rowNum]
         
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == newAlertSegueIdentifier {
            let nextVC = segue.destination as! NewAlertViewController
            
            let categoryIndex:Int = tableView.indexPathForSelectedRow?.row ?? 0
            
            nextVC.alertCategory = categoriesList[categoryIndex]
        }
    }
    

}
