//
//  EmptyDataView.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class EmptyDataView: UIView {
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.photosVideosViewNoPhotoTitleText
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14)
        }
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var actionButton: UIButton!
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        
    }
}
