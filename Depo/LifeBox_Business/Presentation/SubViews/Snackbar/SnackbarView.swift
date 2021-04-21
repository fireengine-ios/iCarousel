//
//  SnackbarView.swift
//  Depo
//
//  Created by Andrei Novikau on 4/22/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SnackbarView: UIView, NibInit {
    
    @IBOutlet private weak var contentView: UIStackView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardMediumFont(size: 16)
            newValue.textColor = .white
            newValue.lineBreakMode = .byTruncatingTail
        }
    }

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(ColorConstants.blueColor.color, for: .normal)
        button.titleLabel?.font = .GTAmericaStandardMediumFont(size: 16)
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
        
        backgroundColor = ColorConstants.snackbarGray.color
    }
    
    static func with(type: SnackbarType, message: String, actionType: SnackbarAction?, axis: NSLayoutConstraint.Axis, action: VoidHandler?) -> SnackbarView {
        let view = SnackbarView.initFromNib()
        
        view.titleLabel.numberOfLines = type.numberOfLinesLimit
        view.titleLabel.text = message
        
        if let actionTitle = actionType?.localizedTitle {
            view.actionButton.setTitle(actionTitle, for: .normal)
            view.setup(axis: axis)
            view.action = action
        }

        switch actionType {
        case .trashBin:
            view.actionButton.setTitleColor(ColorConstants.snackBarTrashBin.color, for: .normal)
        case .ok, .some:
            view.actionButton.setTitleColor(ColorConstants.blueColor.color, for: .normal)
        case .none:
            break
        }

        return view
    }

    private func setup(axis: NSLayoutConstraint.Axis) {
        contentView.axis = axis

        if axis == .horizontal {
            contentView.alignment = .fill
            contentView.distribution = .equalSpacing
        } else {
            contentView.distribution = .fill
            contentView.alignment = .fill
        }
        
        switch axis {
        case .horizontal:
            contentView.addArrangedSubview(actionButton)
        case .vertical:
            let container = UIView()
            container.backgroundColor = backgroundColor
            container.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(actionButton)
            container.leadingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor).activate()
            container.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor).activate()
            container.topAnchor.constraint(equalTo: actionButton.topAnchor).activate()
            container.bottomAnchor.constraint(equalTo: actionButton.bottomAnchor).activate()
            container.heightAnchor.constraint(equalToConstant: 20).activate()
            
            contentView.addArrangedSubview(container)
        }
    }
    
    @objc private func onActionButtonTap() {
        action?()
    }
}
