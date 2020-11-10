//
//  PrivateShareUserRoleViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PrivateShareUserRoleViewControllerDelegate: class {
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
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.setTitleColor(ColorConstants.marineFour, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 19)
            
            if let image = UIImage(named: "arrow2")?.withRenderingMode(.alwaysTemplate) {
                newValue.setImage(image, for: .normal)
                newValue.tintColor = ColorConstants.marineFour
                newValue.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
            }
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.privateShareRoleSelectionTitle
            newValue.font = .TurkcellSaturaBolFont(size: 19)
            newValue.textColor = ColorConstants.marineFour
        }
    }
    
    @IBOutlet private weak var roleStackView: UIStackView!
    
    private(set) var contact: PrivateShareContact?
    private weak var delegate: PrivateShareUserRoleViewControllerDelegate?
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRolesStackView()
    }
    
    private func setupRolesStackView() {
        let roles = PrivateShareUserRole.allCases
        roles.enumerated().forEach { index, role in
            let view = PrivateShareRoleCheckmarkView.with(role: role, delegate: self)
            view.isSelected = contact?.role == role
            roleStackView.addArrangedSubview(view)
            
            let offset: CGFloat = index == roles.count - 1 ? 0 : 16
            let separator = makeSeparator(offset: offset)
            roleStackView.addArrangedSubview(separator)
            separator.heightAnchor.constraint(equalToConstant: 1).activate()
        }
    }
    
    @IBAction private func onBackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func makeSeparator(offset: CGFloat) -> UIView {
        var frame = CGRect(origin: .zero, size: CGSize(width: roleStackView.frame.width, height: 1))
        let view = UIView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        frame.origin.x = offset
        frame.size.width -= offset * 2
        let separator = UIView(frame: frame)
        separator.backgroundColor = ColorConstants.darkBorder.withAlphaComponent(0.3)
        view.addSubview(separator)
        separator.autoresizingMask = [.flexibleWidth]
        return view
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
