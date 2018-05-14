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
            nameLabel.textColor = ColorConstants.lightText
            nameLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        }
    }
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.textColor = ColorConstants.textGrayColor
            dateLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        }
    }
    
    @IBOutlet weak var dataUsageLabel: UILabel! {
        didSet {
            dataUsageLabel.textColor = ColorConstants.textGrayColor
            dataUsageLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        }
    }
    
    func fill(with object: InternetDataUsage) {
        nameLabel.text = object.offerName
        dateLabel.text = object.expiryDate?.getDateInFormat(format: "dd MMM YYYY")
        
        dataUsageLabel.text = String(format: TextConstants.usageInfoBytesRemainedLifebox, object.remainingString, object.totalString)
        progressBar.progress = Float(object.remaining ?? 1) / Float(object.total ?? 1)
    }
}
