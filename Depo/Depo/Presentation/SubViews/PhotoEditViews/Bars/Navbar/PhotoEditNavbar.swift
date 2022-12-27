//
//  PhotoEditNavbar.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditNavbarDelegate: AnyObject {
    func onClose()
    func onSavePhoto()
    func onMoreActions()
    func onSharePhoto()
}

final class PhotoEditNavbar: UIView, NibInit {

    enum State {
        case initial
        case edit
        case editContainsStickers
        case share
        case empty
        
        var buttonsHiddenValues: (close: Bool, save: Bool, saveAsCopy: Bool, share: Bool, more: Bool) {
            switch self {
            case .initial:
                return (close: false, save: true, saveAsCopy: true, share: true, more: true)
            case .edit:
                return (close: false, save: false, saveAsCopy: true, share: true, more: false)
            case .editContainsStickers:
                return (close: false, save: true, saveAsCopy: false, share: true, more: false)
            case .share:
                return (close: false, save: true, saveAsCopy: true, share: false, more: true)
            case .empty:
                return (close: true, save: true, saveAsCopy: true, share: true, more: true)
            }
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.tintColor = .white
            newValue.setImage(Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @IBOutlet private weak var saveButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.photoEditNavBarSave, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: Device.isIpad ? 20 : 16)
        }
    }
    @IBOutlet weak var saveAsCopyButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.photoEditSaveAsCopy, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: Device.isIpad ? 20 : 16)
        }
    }

    @IBOutlet private(set) weak var moreButton: UIButton! {
        willSet {
            newValue.tintColor = .white
            newValue.setImage(Image.iconKebabBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var rightButtonsContainer: UIStackView!
    
    weak var delegate: PhotoEditNavbarDelegate?
    
    var state: State = .initial {
        didSet {
            let values = state.buttonsHiddenValues
            closeButton.isHidden = values.close
            saveButton.isHidden = values.save
            saveAsCopyButton.isHidden = values.saveAsCopy
            shareButton.isHidden = values.share
            moreButton.isHidden = values.more
        }
    }
    
    //MARK: - Actions
    
    @IBAction private func onClose(_ sender: UIButton) {
        delegate?.onClose()
    }
    
    @IBAction private func onSave(_ sender: UIButton) {
        delegate?.onSavePhoto()
    }

    @IBAction private func onSaveAsCopy(_ sender: UIButton) {
        delegate?.onSavePhoto()
    }

    @IBAction private func onMore(_ sender: UIButton) {
        delegate?.onMoreActions()
    }
    
    @IBAction private func onShare(_ sender: UIButton) {
        delegate?.onSharePhoto()
    }
}
