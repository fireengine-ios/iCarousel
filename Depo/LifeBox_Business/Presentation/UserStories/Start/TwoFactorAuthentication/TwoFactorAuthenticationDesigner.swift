//
//  TwoFactorAuthenticationDesigner.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class TwoFactorAuthenticationDesigner: NSObject {

    @IBOutlet private weak var errorView: ErrorBannerView! {
        willSet {
            newValue.errorLabelTextColor = ColorConstants.loginErrorLabelText
            newValue.errorLabelTextFont = UIFont.GTAmericaStandardRegularFont(size: 12)
            newValue.errorTextAlignment = .center
            newValue.backgroundColor = .clear
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var reasonLabel: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 18)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.textColor = ColorConstants.loginPopupDescription
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.text = TextConstants.a2FAFirstPageDescriptionDetail
        }
    }
    
    @IBOutlet private weak var setTypeOfAuthenticationLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.text = TextConstants.a2FAFirstPageSendSecurityCode
            newValue.textColor = ColorConstants.Text.labelTitle
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
            newValue.separatorColor = .clear
            newValue.backgroundColor = ColorConstants.tableBackground
            newValue.tableFooterView = UIView()
            newValue.tableHeaderView = UIView()
            newValue.separatorStyle = .none
        }
    }
    
    @IBOutlet private weak var sendButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.a2FAFirstPageButtonSend, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.backgroundColor = ColorConstants.bottomBarTint
            newValue.isOpaque = true
            newValue.layer.cornerRadius = 5
        }
    }

    @IBOutlet private weak var contentViewHeightToScrollInnerViewConstaint: NSLayoutConstraint! {
        willSet {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0
            if topPadding > 20 {
                newValue.constant = -topPadding
            }
        }
    }
}
