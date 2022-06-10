//
//  SharedItemsSegmentView.swift
//  Depo
//
//  Created by Burak Donat on 9.06.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

enum SharedItemsSegment: CaseIterable {
    case sharedWithMe
    case sharedByMe
}

protocol SharedItemsSegmentViewDelegate: AnyObject {
    func sharedSegmentChanged(to index: Int)
}

class SharedItemsSegmentView: UIView, NibInit {
    
    weak var delegate: SharedItemsSegmentViewDelegate?
    
    @IBOutlet weak var sharedSegmentControl: UISegmentedControl! {
        willSet {
            newValue.setTitle(TextConstants.privateShareSharedWithMeTab, forSegmentAt: 0)
            newValue.setTitle(TextConstants.privateShareSharedByMeTab, forSegmentAt: 1)
            newValue.backgroundColor = .clear
            newValue.tintColor = .clear
            newValue.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
            newValue.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            newValue.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.appFont(.medium, size: 14)],
                                                        for: .normal)
            newValue.setTitleTextAttributes([.foregroundColor: AppColor.filesLabel.color], for: .normal)
        }
    }
    
    @IBAction func sharedSegmentChanged(_ sender: UISegmentedControl) {
        sharedSegmentControl.changeUnderlinePosition()
        delegate?.sharedSegmentChanged(to: sender.selectedSegmentIndex)
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func reset() {
        sharedSegmentControl.selectedSegmentIndex = 0
        sharedSegmentControl.changeUnderlinePosition()
    }
}
