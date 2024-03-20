//
//  AnalyzeHistoryEmptyCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class AnalyzeHistoryEmptyCell: UICollectionViewCell, NibInit {
    
    @IBOutlet private weak var emptyTitleLabel: UILabel!     
    @IBOutlet private weak var emptySubtitleLabel: UILabel! 

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        emptyTitleLabel.text = TextConstants.analyzeHistoryEmptyTitle
        emptyTitleLabel.textColor = ColorConstants.darkText
        emptyTitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.numberOfLines = 0
        
        emptySubtitleLabel.text = TextConstants.analyzeHistoryEmptySubtitle
        emptySubtitleLabel.textColor = ColorConstants.textGrayColor
        emptySubtitleLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0
    }
    
}
