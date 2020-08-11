//
//  FilterChangesBar.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol FilterChangesBarDelegate: class {
    func cancelFilter()
    func applyFilter()
}

final class FilterChangesBar: UIView, NibInit {

    static func with(title: String, delegate: FilterChangesBarDelegate?) -> FilterChangesBar {
        let view = FilterChangesBar.initFromNib()
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
    
    @IBOutlet private weak var cancelButton: UIButton!
    
    @IBOutlet private weak var applyButton: UIButton!
    
    private weak var delegate: FilterChangesBarDelegate?
    
    @IBAction private func onCancel(_ sender: UIButton) {
        delegate?.cancelFilter()
    }
    
    @IBAction private func onApply(_ sender: UIButton) {
        delegate?.applyFilter()
    }
}
