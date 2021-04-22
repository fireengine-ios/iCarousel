//
//  ActivityTimelineTimeCell.swift
//  Depo
//
//  Created by user on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ActivityTimelineTimeCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.textColor = ColorConstants.darkText.color
            timeLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
        }
    }
    @IBOutlet weak var fileTypeLabel: UILabel! {
        didSet {
            fileTypeLabel.textColor = ColorConstants.darkText.color
            fileTypeLabel.font = UIFont.TurkcellSaturaDemFont(size: 15)
        }
    }
}
