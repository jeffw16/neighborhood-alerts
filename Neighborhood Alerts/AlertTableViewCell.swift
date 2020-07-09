//
//  AlertTableViewCell.swift
//  Neighborhood Alerts
//
//  Created by Jeffrey Wang on 7/5/20.
//  Copyright © 2020 MyWikis LLC. All rights reserved.
//

import UIKit

class AlertTableViewCell: UITableViewCell {
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertDescription: UILabel!
    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
}
