//
//  AnalyzeHistoryDesigner.swift
//  Depo
//
//  Created by Andrei Novikau on 1/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class AnalyzeHistoryDesigner: NSObject {
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            
        }
    }
    
    @IBOutlet private weak var emptyTitleLabel: UILabel! {
        willSet {
            emptyTitleLabel.textColor = ColorConstants.darkText
            emptyTitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
            emptyTitleLabel.textAlignment = .center
            emptyTitleLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var emptySubtitleLabel: UILabel! {
        willSet {
            emptySubtitleLabel.textColor = ColorConstants.textGrayColor
            emptySubtitleLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
            emptySubtitleLabel.textAlignment = .center
            emptySubtitleLabel.numberOfLines = 0
        }
    }
}
