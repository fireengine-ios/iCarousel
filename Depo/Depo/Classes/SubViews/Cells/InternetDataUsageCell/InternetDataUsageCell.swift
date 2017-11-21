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
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.darkText
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    func fill(with object: InternetDataUsage) {
        titleLabel.text = "Remaning \(object.remainingString) of \(object.totalString)"
        progressBar.progress = Float(object.remaining ?? 1) / Float(object.total ?? 1)
    }
}
