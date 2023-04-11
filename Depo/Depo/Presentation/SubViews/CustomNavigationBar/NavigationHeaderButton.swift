//
//  NavigationHeaderButton.swift
//  Depo
//
//  Created by Hady on 4/20/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

final class NavigationHeaderButton: UIButton {
    
    private lazy var notificationLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.bold, size: 12)
        view.textColor = .white
        return view
    }()
    
    convenience init(type: `Type`, target: Any? = nil, action: Selector? = nil) {
        self.init()
        setImage(type.image?.image, for: .normal)
        accessibilityIdentifier = type.accessibilityId
        accessibilityLabel = type.accessibilityLabel
        if let target = target, let action = action {
            addTarget(target, action: action, for: .primaryActionTriggered)
        }
        
        if type == .settings {
            addNotification()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 28, height: 28)
    }
    
    
}

extension NavigationHeaderButton {
    
    private func addNotification() {
        let earingView = UIView()
        earingView.isHidden = true
        earingView.backgroundColor = AppColor.notification.color
        earingView.layer.cornerRadius = 9
        
        earingView.addSubview(notificationLabel)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.centerYAnchor.constraint(equalTo: earingView.centerYAnchor).activate()
        notificationLabel.centerXAnchor.constraint(equalTo: earingView.centerXAnchor).activate()
        
        
        addSubview(earingView)
        earingView.translatesAutoresizingMaskIntoConstraints = false
        earingView.topAnchor.constraint(equalTo: topAnchor, constant: -6).activate()
        earingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10).activate()
        earingView.heightAnchor.constraint(equalToConstant: 18).activate()
        earingView.widthAnchor.constraint(equalToConstant: 18).activate()
    }
    
    func setnotificationCount(with number: Int) {
        notificationLabel.superview?.isHidden = number == 0 ? true : false
        
        let strNum = String(number)
        notificationLabel.text = number > 9 ? "9+" : strNum
    }
    
    enum `Type` {
        case settings
        case search
        case plus

        var image: NavigationBarImage? {
            switch self {
            case .settings:
                return .headerActionSettings
            case .search:
                return .headerActionSearch
            case .plus:
                return .headerActionPlus
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .settings:
                return TextConstants.settings
            case .search:
                return TextConstants.search
            case .plus:
                return TextConstants.accessibilityPlus
            }
        }

        var accessibilityId: String {
            switch self {
            case .settings:
                return "NavigationHeaderButtonSettings"
            case .search:
                return "NavigationHeaderButtonSearch"
            case .plus:
                return "NavigationHeaderButtonPlus"
            }
        }
    }
}
