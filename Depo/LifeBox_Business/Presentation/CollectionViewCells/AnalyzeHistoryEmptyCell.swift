//
//  AnalyzeHistoryEmptyCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class AnalyzeHistoryEmptyCell: UICollectionViewCell, NibInit {
    
    @IBOutlet private weak var emptyTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.analyzeHistoryEmptyTitle
            newValue.textColor = ColorConstants.darkText
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 20)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var emptySubtitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.analyzeHistoryEmptySubtitle
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
}
