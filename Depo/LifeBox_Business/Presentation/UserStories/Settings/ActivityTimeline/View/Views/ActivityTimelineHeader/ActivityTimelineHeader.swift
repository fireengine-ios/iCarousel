//
//  ActivityTimelineHeader.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ActivityTimelineHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var dayLabel: UILabel! {
        didSet {
            dayLabel.textColor = ColorConstants.darkText.color
            dayLabel.font = UIFont.GTAmericaStandardDemiBoldFont(size: 18)
        }
    }
}
