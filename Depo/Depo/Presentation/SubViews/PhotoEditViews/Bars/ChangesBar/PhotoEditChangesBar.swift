//
//  PhotoEditChangesBar.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditChangesBarDelegate: AnyObject {
    func cancelChanges()
    func applyChanges()
}

final class PhotoEditChangesBar: UIView, NibInit {

    static func with(title: String, delegate: PhotoEditChangesBarDelegate?) -> PhotoEditChangesBar {
        let view = PhotoEditChangesBar.initFromNib()
        view.delegate = delegate
        view.titleLabel.text = title
        return view
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.textAlignment = .center
            newValue.font = .TurkcellSaturaMedFont(size: 16)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var applyButton: UIButton!
    
    private weak var delegate: PhotoEditChangesBarDelegate?
    
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
}
