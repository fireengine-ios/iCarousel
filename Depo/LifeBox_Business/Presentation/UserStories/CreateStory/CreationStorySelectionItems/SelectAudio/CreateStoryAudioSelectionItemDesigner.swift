//
//  CreateStoryAudioSelectionItemDesigner.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 7/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStoryAudioSelectionItemDesigner: NSObject {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        willSet {
            newValue.setTitle(TextConstants.createStoryAudioMusics, forSegmentAt: 0)
            newValue.setTitle(TextConstants.createStoryAudioYourUploads, forSegmentAt: 1)
            newValue.tintColor = ColorConstants.darkBlueColor
        }
    }
    
    @IBOutlet private weak var emtyListView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var emtyListLabel: UILabel! {
        willSet{
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14)
            newValue.text = TextConstants.audioViewNoAudioTitleText
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(nibCell: CreateStoryAudioItemCell.self)
            newValue.backgroundColor = UIColor.clear
            newValue.tableFooterView = UIView()
        }
    }
    
}
