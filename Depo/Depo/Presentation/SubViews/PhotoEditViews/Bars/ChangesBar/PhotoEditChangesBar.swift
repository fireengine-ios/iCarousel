//
//  PhotoEditChangesBar.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditChangesBarDelegate: class {
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
            newValue.font = .TurkcellSaturaDemFont(size: 14)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "photo_edit_cancel"), for: .normal)
        }
    }
    
    @IBOutlet private weak var applyButton: UIButton! {
           willSet {
               newValue.setImage(UIImage(named: "photo_edit_apply"), for: .normal)
           }
       }
    
    private weak var delegate: PhotoEditChangesBarDelegate?
    
    @IBAction private func onCancel(_ sender: UIButton) {
        delegate?.cancelChanges()
    }
    
    @IBAction private func onApply(_ sender: UIButton) {
        delegate?.applyChanges()
    }
}
