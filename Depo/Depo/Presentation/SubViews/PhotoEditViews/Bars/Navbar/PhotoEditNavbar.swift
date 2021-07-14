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
        case share
        case empty
        
        var buttonsHiddenValues: (close: Bool, save: Bool, share: Bool, more: Bool) {
            switch self {
            case .initial:
                return (close: false, save: true, share: true, more: true)
            case .edit:
                return (close: false, save: false, share: true, more: false)
            case .share:
                return (close: false, save: true, share: false, more: true)
            case .empty:
                return (close: true, save: true, share: true, more: true)
            }
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.photoEditNavBarSave, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: Device.isIpad ? 20 : 16)
        }
    }
    
    @IBOutlet private(set) weak var moreButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var rightButtonsContainer: UIStackView!
    
    weak var delegate: PhotoEditNavbarDelegate?
    
    var state: State = .initial {
        didSet {
            let values = state.buttonsHiddenValues
            closeButton.isHidden = values.close
            saveButton.isHidden = values.save
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
    
    @IBAction private func onMore(_ sender: UIButton) {
        delegate?.onMoreActions()
    }
    
    @IBAction private func onShare(_ sender: UIButton) {
        delegate?.onSharePhoto()
    }
}
