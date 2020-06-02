//
//  ContactSyncProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 28.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactSyncProgressView: UIView, NibInit {
    
    static func setup(title: String, message: String) -> ContactSyncProgressView {
        let view = ContactSyncProgressView.initFromNib()
        view.title.text = title
        view.message.text = message
        
        return view
    }
    
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
            newValue.numberOfLines = 0
            newValue.font = .TurkcellSaturaFont(size: 16.0)
            newValue.textColor = ColorConstants.lightGray
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    @IBOutlet private weak var loader: CircleLoaderView! {
        willSet {
            newValue.resetProgress()
            newValue.set(lineColor: ColorConstants.navy)
            newValue.set(lineBackgroundColor: ColorConstants.lighterGray)
        }
    }
    
    func reset() {
        loader.resetProgress()
    }
    
    func update(progress: Int) {
        loader.set(progress: progress)
    }
}
