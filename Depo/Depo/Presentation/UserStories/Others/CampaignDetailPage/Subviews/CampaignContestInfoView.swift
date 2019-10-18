//
//  CampaignContestInfoView.swift
//  Depo
//
//  Created by Andrei Novikau on 10/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CampaignContestInfoView: UIView {
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailContestInfoTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textColor = ColorConstants.darkText
            newValue.textAlignment = .center
        }
    }
    
    @IBOutlet private weak var totalDrawLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailContestInfoTotalDraw
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 14)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var remainingDrawLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.campaignDetailContestInfoRemainingDraw
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 14)
            newValue.textColor = ColorConstants.textGrayColor
        }
    }
    
    @IBOutlet private weak var totalCountLabel: UILabel! {
        willSet {
            newValue.text = "5"
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 21)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    @IBOutlet private weak var remainingCountLabel: UILabel! {
        willSet {
            newValue.text = "10"
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 21)
            newValue.textColor = ColorConstants.darkText
        }
    }
    
    private func setup() {
        
    }

}
