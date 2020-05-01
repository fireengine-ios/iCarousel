//
//  SnackbarView.swift
//  Depo
//
//  Created by Andrei Novikau on 4/22/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SnackbarView: UIView, NibInit {
    
    @IBOutlet private weak var contentView: UIStackView! {
        willSet {
            newValue.spacing = 8
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .white
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(ColorConstants.blueColor, for: .normal)
        button.titleLabel?.font = .TurkcellSaturaDemFont(size: 16)
        button.contentHorizontalAlignment = .right
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        button.addTarget(self, action: #selector(onActionButtonTap), for: .touchUpInside)
        return button
    }()
    
    private var action: VoidHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.snackbarGray
    }
    
    func setup(message: String, actionTitle: String?, axis: NSLayoutConstraint.Axis, action: VoidHandler?) {
        titleLabel.text = message
        
        guard actionTitle != nil else {
            return
        }
        
        actionButton.setTitle(actionTitle, for: .normal)
        setup(axis: axis)
        self.action = action
    }

    private func setup(axis: NSLayoutConstraint.Axis) {
        contentView.axis = axis
        
        switch axis {
        case .horizontal:
            contentView.addArrangedSubview(actionButton)
        case .vertical:
            let container = UIView()
            container.backgroundColor = backgroundColor
            container.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(actionButton)
            container.leadingAnchor.constraint(greaterThanOrEqualTo: actionButton.leadingAnchor).activate()
            container.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor).activate()
            container.topAnchor.constraint(equalTo: actionButton.topAnchor).activate()
            container.bottomAnchor.constraint(equalTo: actionButton.bottomAnchor).activate()
            
            contentView.addArrangedSubview(container)
        }
    }
    
    @objc private func onActionButtonTap() {
        action?()
    }
}
