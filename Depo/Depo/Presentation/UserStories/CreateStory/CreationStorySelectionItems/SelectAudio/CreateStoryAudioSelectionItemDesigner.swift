//
//  CreateStoryAudioSelectionItemDesigner.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 7/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStoryAudioSelectionItemDesigner: NSObject {
    
    @IBOutlet private weak var emtyListView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var emtyListLabel: UILabel! {
        willSet{
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 16)
            newValue.text = TextConstants.audioViewNoAudioTitleText
            newValue.numberOfLines = 0
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
