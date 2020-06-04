//
//  ContactSyncProgressView.swift
//  Depo
//
//  Created by Konstantin Studilin on 28.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum ContactSyncProgressType {
    case backup
    case deleteDuplicates
    case restore
    
    var title: String {
        switch self {
        case .backup:
            return TextConstants.contactSyncBackupProgressTitle
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesProgressTitle
        case .restore:
            return TextConstants.restoreContactsRestoreTitle
        }
    }
    
    var message: String {
        switch self {
        case .backup:
            return TextConstants.contactSyncBackupProgressMessage
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesProgressMessage
        case .restore:
            return TextConstants.restoreContactsRestoreMessage
        }
    }
}

final class ContactSyncProgressView: UIView, NibInit {
    
    static func setup(type: ContactSyncProgressType) -> ContactSyncProgressView {
        let view = ContactSyncProgressView.initFromNib()
        view.title.text = type.title
        view.message.text = type.message
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
