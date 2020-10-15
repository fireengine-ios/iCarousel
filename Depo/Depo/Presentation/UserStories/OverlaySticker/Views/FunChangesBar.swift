//
//  FunChangesBar.swift
//  Depo
//
//  Created by Andrei Novikau on 10/8/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol FunChangesBarDelegate: class {
    func cancelChanges()
    func applyChanges()
}

final class FunChangesBar: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.textAlignment = .center
            newValue.font = .TurkcellSaturaMedFont(size: 16)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var applyButton: UIButton!
    
    weak var delegate: FunChangesBarDelegate?
    
    @IBAction private func onCancel(_ sender: UIButton) {
        delegate?.cancelChanges()
    }
    
    @IBAction private func onApply(_ sender: UIButton) {
        delegate?.applyChanges()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = ColorConstants.photoEditBackgroundColor
        heightAnchor.constraint(equalToConstant: Device.isIpad ? 60 : 44).activate()
    }
    
    func setup(with title: String) {
        titleLabel.text = title
    }
}
