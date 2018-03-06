//
//  DocumentActionCustomizator.swift
//  LifeboxFileProviderUI
//
//  Created by Bondar Yaroslav on 3/6/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class DocumentActionCustomizator: NSObject {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.darkText
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel!  {
        didSet {
            messageLabel.textColor = ColorConstants.lightText
            messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
}
