//
//  ActivityTimelineFileCell.swift
//  Depo
//
//  Created by user on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ActivityTimelineFileCell: UITableViewCell {

    @IBOutlet weak var fileNameLabel: UILabel! = UILabel() {
        didSet {
            fileNameLabel.textColor = ColorConstants.darkText.color
            fileNameLabel.font = UIFont.GTAmericaStandardDemiBoldFont(size: 15)
        }
    }
    @IBOutlet weak var fileImageView: UIImageView!
    
    func fill(with activity: ActivityTimelineServiceResponse) {
        fileNameLabel.text = activity.name
        fileImageView?.image = activity.activityFileType?.image
    }
}
