//
//  FunNavBar.swift
//  Depo
//
//  Created by Andrei Novikau on 10/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol FunNavBarDelegate: class {
    func funNavBarDidCloseTapped()
    func funNavBarDidSaveTapped()
    func funNavBarDidUndoTapped()
}

final class FunNavBar: UIView {
    
    enum FunState {
        case initial
        case edit
        case modify
    }
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.save, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: Device.isIpad ? 20 : 16)
        }
    }
    @IBOutlet private weak var undoButton: UIButton!
    
    weak var delegate: FunNavBarDelegate?
    
    var state: FunState = .initial {
        didSet {
            switch state {
            case .initial:
                closeButton.isHidden = false
                saveButton.isHidden = true
                undoButton.isHidden = true
                
            case .edit:
                closeButton.isHidden = false
                saveButton.isHidden = false
                undoButton.isHidden = true
                
            case .modify:
                closeButton.isHidden = true
                saveButton.isHidden = true
                undoButton.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .black
    }
    
    //MARK: - Actions
    
    @IBAction private func onClose(_ sender: UIButton) {
        delegate?.funNavBarDidCloseTapped()
    }
    
    @IBAction private func onSave(_ sender: UIButton) {
        delegate?.funNavBarDidSaveTapped()
    }
    
    @IBAction private func onUndo(_ sender: UIButton) {
        delegate?.funNavBarDidUndoTapped()
    }
}
