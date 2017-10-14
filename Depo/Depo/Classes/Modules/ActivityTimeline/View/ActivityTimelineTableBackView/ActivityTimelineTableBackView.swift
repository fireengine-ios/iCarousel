//
//  ActivityTimelineTableBackView.swift
//  Depo_LifeTech
//
//  Created by user on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class ActivityTimelineTableBackView: UIView {

    static var fromNib: ActivityTimelineTableBackView {
        return UINib(nibName: "ActivityTimelineTableBackView", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ActivityTimelineTableBackView
    }
}
