//
//  CheckBoxView.swift
//  Depo
//
//  Created by Andrei Novikau on 18/05/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol CheckBoxViewDelegate: class {
    func openAutoSyncSettings()
    func openViewTypeMenu(sender: UIButton)
}

enum GalleryViewType: CaseIterable {
    case all
    case synced
    case unsynced
    
    var title: String {
        switch self {
        case .all:
            return TextConstants.galleryFilterAll
        case .synced:
            return TextConstants.galleryFilterSynced
        case .unsynced:
            return TextConstants.galleryFilterUnsynced
        }
    }
    
    private var actionSheetTitle: String {
        switch self {
        case .all:
            return TextConstants.galleryFilterActionSheetAll
        case .synced:
            return TextConstants.galleryFilterActionSheetSynced
        case .unsynced:
            return TextConstants.galleryFilterActionSheetUnsynced
        }
    }
    
    static func createAlertActions(handler: @escaping (_ newType: GalleryViewType) -> Void) -> [UIAlertAction] {
        return Self.allCases.map { type in
            UIAlertAction(title: type.actionSheetTitle, style: .default) { _ in
                handler(type)
            }
        }
    }
}

final class CheckBoxView: UIView, NibInit {

    @IBOutlet private weak var autoSyncSettingsButton: UIButton! {
        willSet {
            newValue.tintColor = .lrTealishTwo
            newValue.setTitle(TextConstants.photosVideosAutoSyncSettings, for: .normal)
            newValue.setTitleColor(.lrTealishTwo, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaBolFont(size: Device.isIphoneSmall ? 11 : 13)
            newValue.titleLabel?.numberOfLines = 2
            newValue.titleLabel?.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var viewTypeButton: UIButton! {
        willSet {
            newValue.tintColor = .lrTealishTwo
            newValue.setTitle(type.title, for: .normal)
            newValue.setTitleColor(ColorConstants.lightText.color, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaRegFont(size: Device.isIphoneSmall ? 12 : 14)
            newValue.titleLabel?.numberOfLines = 2
            newValue.titleLabel?.lineBreakMode = .byWordWrapping
            newValue.forceImageToRightSide()
            newValue.imageEdgeInsets.left = -8
        }
    }
    
    weak var delegate: CheckBoxViewDelegate?
    
    var type: GalleryViewType = .all {
        didSet {
            viewTypeButton.setTitle(type.title, for: .normal)
        }
    }

    @IBAction private func onOpenAutoSyncSettings(_ sender: UIButton) {
        delegate?.openAutoSyncSettings()
    }

    @IBAction private func onOpenViewTypeMenu(_ sender: UIButton) {
        delegate?.openViewTypeMenu(sender: sender)
    }
}
