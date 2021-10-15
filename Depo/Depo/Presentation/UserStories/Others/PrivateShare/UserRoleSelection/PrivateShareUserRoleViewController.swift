//
//  PrivateShareUserRoleViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareUserRoleViewControllerDelegate: AnyObject {
    func contactRoleDidChange(_ contact: PrivateShareContact)
}

final class PrivateShareUserRoleViewController: BaseViewController, NibInit {
    
    static func with(contact: PrivateShareContact, delegate: PrivateShareUserRoleViewControllerDelegate?) -> PrivateShareUserRoleViewController {
        let controller = PrivateShareUserRoleViewController.initFromNib()
        controller.contact = contact
        controller.delegate = delegate
        return controller
    }
    
    @IBOutlet private weak var backButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.backTitle, for: .normal)
            newValue.setTitleColor(AppColor.marineFourAndWhite.color, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 19)
            
            if let image = UIImage(named: "arrow2")?.withRenderingMode(.alwaysTemplate) {
                newValue.setImage(image, for: .normal)
                newValue.tintColor = AppColor.marineFourAndWhite.color
                newValue.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareRoleSelectionTitle
            newValue.font = .TurkcellSaturaBolFont(size: 19)
            newValue.textColor = AppColor.marineFourAndWhite.color
        }
    }
    
    @IBOutlet private weak var displayNameLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var userNameLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = AppColor.blackColor.color
        }
    }
    
    @IBOutlet private weak var roleStackView: UIStackView!
    
    private(set) var contact: PrivateShareContact?
    private weak var delegate: PrivateShareUserRoleViewControllerDelegate?
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameLabel.text = contact?.displayName
        userNameLabel.text = contact?.username
        setupRolesStackView()
    }
    
    private func setupRolesStackView() {
        let roles: [PrivateShareUserRole] = [.editor, .viewer]
        roles.enumerated().forEach { index, role in
            let view = PrivateShareRoleCheckmarkView.with(role: role, delegate: self)
            view.isSelected = contact?.role == role
            roleStackView.addArrangedSubview(view)
            
            let offset: CGFloat = index == roles.count - 1 ? 0 : 16
            let separator = UIView.makeSeparator(width: roleStackView.frame.width, offset: offset)
            roleStackView.addArrangedSubview(separator)
            separator.heightAnchor.constraint(equalToConstant: 1).activate()
        }
    }
    
    @IBAction private func onBackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

//MARK: - PrivateShareRoleCheckmarkViewDelegate

extension PrivateShareUserRoleViewController: PrivateShareRoleCheckmarkViewDelegate {
    
    func didSelect(role: PrivateShareUserRole) {
        contact?.role = role
        roleStackView.arrangedSubviews.forEach {
            if let roleView = $0 as? PrivateShareRoleCheckmarkView {
                roleView.isSelected = roleView.role == role
            }
        }
        
        if let contact = contact {
            delegate?.contactRoleDidChange(contact)
        }
    }
}
