//
//  ContactSyncProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 28.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactSyncProgressView: UIView, NibInit {
    
    @IBOutlet private weak var title: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = .TurkcellSaturaDemFont(size: 24.0)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = .TurkcellSaturaFont(size: 16.0)
            newValue.textColor = ColorConstants.lighterGray
        }
    }
    @IBOutlet private weak var loader: GradientLoadingIndicator! {
        willSet {
            newValue.resetProgress()
        }
    }
    
    func update(progress: Float) {
        loader.progress = CGFloat(progress)
    }
}
