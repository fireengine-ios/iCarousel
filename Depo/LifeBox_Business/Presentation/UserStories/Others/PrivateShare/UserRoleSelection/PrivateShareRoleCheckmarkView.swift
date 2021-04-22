//
//  PrivateShareRoleCheckmarkView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareRoleCheckmarkViewDelegate: class {
    func didSelect(role: PrivateShareUserRole)
}

final class PrivateShareRoleCheckmarkView: UIView, NibInit {
    
    static func with(role: PrivateShareUserRole, delegate: PrivateShareRoleCheckmarkViewDelegate?) -> PrivateShareRoleCheckmarkView {
        let view = PrivateShareRoleCheckmarkView.initFromNib()
        view.delegate = delegate
        view.setup(with: role)
        return view
    }
    
    @IBOutlet private weak var button: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setTitleColor(ColorConstants.marineFour.color, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var checkmarkImageView: UIImageView! {
        willSet {
            if let image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate) {
                newValue.image = image.mask(with: ColorConstants.marineFour.color)
            }
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            checkmarkImageView.isHidden = !isSelected
        }
    }
    
    private weak var delegate: PrivateShareRoleCheckmarkViewDelegate?
    private(set) var role: PrivateShareUserRole = .viewer

    private func setup(with role: PrivateShareUserRole) {
        button.setTitle(role.selectionTitle, for: .normal)
        self.role = role
    }
    
    @IBAction private func onButtonTapped(_ sender: UIButton) {
        delegate?.didSelect(role: role)
    }
}
