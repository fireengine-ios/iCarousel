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
            return TextConstants.restoreContactsProgressTitle
        }
    }
    
    var message: String {
        switch self {
        case .backup:
            return TextConstants.contactSyncBackupProgressMessage
        case .deleteDuplicates:
            return TextConstants.deleteDuplicatesProgressMessage
        case .restore:
            return TextConstants.restoreContactsProgressMessage
        }
    }
    
    static func convertSyncOperationType(_ type: SyncOperationType) -> ContactSyncProgressType? {
        switch type {
        case .backup:
            return .backup
        case .deleteDuplicated:
            return .deleteDuplicates
        case .restore:
            return .restore
        default:
            return nil
        }
    }
}

final class ContactSyncProgressView: UIView, NibInit, ContactOperationProgressView {
    
    static func setup(type: SyncOperationType) -> ContactSyncProgressView {
        let view = ContactSyncProgressView.initFromNib()
        view.type = type
        if let progressType = ContactSyncProgressType.convertSyncOperationType(type) {
            view.title.text = progressType.title
            view.message.text = progressType.message
        }
        return view
    }
    
    @IBOutlet private weak var title: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = .appFont(.medium, size: 14.0)
            newValue.textColor = AppColor.marineTwoAndWhite.color
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.textAlignment = .center
            newValue.font = .appFont(.regular, size: 14.0)
            newValue.textColor = ColorConstants.lightGray
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    @IBOutlet private weak var loader: CircleLoaderView! {
        willSet {
            newValue.resetProgress()
            newValue.set(lineColor: AppColor.progressFront.color)
            newValue.set(lineBackgroundColor: ColorConstants.lighterGray)
        }
    }
    
    var type: SyncOperationType!
    
    func reset() {
        loader.resetProgress()
    }
    
    func update(progress: Int) {
        loader.set(progress: progress)
    }
}
