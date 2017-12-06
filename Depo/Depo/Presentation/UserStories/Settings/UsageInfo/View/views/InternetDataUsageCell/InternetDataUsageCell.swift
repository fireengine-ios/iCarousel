//
//  InternetDataUsageCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/25/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class InternetDataUsageCell: UITableViewCell {
    
    @IBOutlet weak var progressBar: RoundedProgressView! {
        didSet {
            progressBar.progressTintColor = ColorConstants.greenColor
            progressBar.trackTintColor = ColorConstants.lightGrayColor
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.textColor = ColorConstants.darkText
            nameLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.textColor = ColorConstants.darkText
            dateLabel.font = UIFont.TurkcellSaturaDemFont(size: 15)
        }
    }
    
    @IBOutlet weak var dataUsageLabel: UILabel! {
        didSet {
            dataUsageLabel.textColor = ColorConstants.darkText
            dataUsageLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
        }
    }
    
    func fill(with object: InternetDataUsage) {
        nameLabel.text = object.offerName
        dateLabel.text = object.expiryDate?.getDateInFormat(format: "dd.MM.YYYY")
        dataUsageLabel.text = "\(object.remainingString) of \(object.totalString) has remained"
        progressBar.progress = Float(object.remaining ?? 1) / Float(object.total ?? 1)
    }
}
