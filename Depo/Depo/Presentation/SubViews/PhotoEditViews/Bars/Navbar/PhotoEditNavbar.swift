//
//  PhotoEditNavbar.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditNavbarDelegate: class {
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
    }
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton! {
        willSet {
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 13)
        }
    }
    
    @IBOutlet private(set) weak var moreButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var rightButtonsContainer: UIStackView!
    
    weak var delegate: PhotoEditNavbarDelegate?
    
    var state: State = .initial {
        didSet {
            switch state {
            case .initial:
                saveButton.isHidden = true
                shareButton.isHidden = true
                moreButton.isHidden = true
            case .edit:
                saveButton.isHidden = false
                shareButton.isHidden = true
                moreButton.isHidden = false
            case .share:
                saveButton.isHidden = true
                shareButton.isHidden = false
                moreButton.isHidden = true
            }
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
