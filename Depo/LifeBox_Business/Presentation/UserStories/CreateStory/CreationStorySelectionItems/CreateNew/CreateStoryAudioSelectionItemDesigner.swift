//
//  CreateStoryAudioSelectionItemDesigner.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 7/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStoryAudioSelectionItemDesigner: NSObject {
    
    @IBOutlet private weak var topIOS10Constraint: NSLayoutConstraint! {
        willSet {
            if #available(iOS 11.0, *) {
                newValue.constant = 0
            }
        }
    }
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl! {
        willSet {
            newValue.setTitle(TextConstants.createStoryAudioMusics, forSegmentAt: 0)
            newValue.setTitle(TextConstants.createStoryAudioYourUploads, forSegmentAt: 1)
            newValue.tintColor = ColorConstants.darkBlueColor
        }
    }
    
    @IBOutlet weak var emtyListView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var emtyListLabel: UILabel! {
        willSet{
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14)
            newValue.text = TextConstants.audioViewNoAudioTitleText
        }
    }
    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            let nib = UINib.init(nibName: CellsIdConstants.createStoryAudioItemCell,
                                 bundle: nil)
            newValue.register(nib, forCellReuseIdentifier: CellsIdConstants.createStoryAudioItemCell)
            newValue.backgroundColor = UIColor.clear
        }
    }
}
