//
//  TwoFactorAuthenticationDesigner.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TwoFactorAuthenticationDesigner: NSObject {
    
    @IBOutlet private weak var reasonLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaFont(size: 35)
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.textColor = ColorConstants.blueGrey
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 15)
            newValue.text = TextConstants.twoFactorAuthenticationDescribeLabel
        }
    }
    
    @IBOutlet private weak var setTypeOfAuthenticationLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 15)
            newValue.text = TextConstants.twoFactorAuthenticationChooseTypeLabel
        }
    }
    
    @IBOutlet weak var topTableViewSeparatorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.profileGrayColor
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.register(nibCell: TwoFactorAuthenticationCell.self)
            newValue.separatorColor = ColorConstants.profileGrayColor
            newValue.backgroundColor = UIColor.clear
            newValue.tableFooterView = UIView()
            newValue.tableHeaderView = UIView()
        }
    }
    
    @IBOutlet private weak var sendButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.feedbackViewSendButton, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.backgroundColor = UIColor.lrTealish
            newValue.isOpaque = true
        }
    }
}
