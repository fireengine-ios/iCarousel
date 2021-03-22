//
//  SnackbarManager.swift
//  Depo
//
//  Created by Andrei Novikau on 4/22/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import TTGSnackbar

enum SnackbarAction {
    case ok
    case trashBin
    case hiddenBin
    
    var localizedTitle: String {
        switch self {
        case .ok:
            return TextConstants.snackbarOk
        case .trashBin:
            return TextConstants.snackbarTrashBin
        case .hiddenBin:
            return TextConstants.snackbarHiddenBin
        }
    }
}

enum SnackbarType {
    case nonCritical
    case critical
    case action
    
    var numberOfLinesLimit: Int {
        switch self {
        case .nonCritical:
            return 2
        case .critical:
            return 3
        case .action:
            return 3
        }
    }
    
    var duration: TTGSnackbarDuration {
        switch self {
        case .nonCritical:
            return .middle
        case .critical:
            return .forever
        case .action:
            return .middle
        }
    }
    
    func action(operationType: ElementTypes) -> SnackbarAction? {
        switch self {
        case .nonCritical:
            return nil
        case .critical:
            return .ok
        case .action:
            switch operationType {
            case .moveToTrash:
                return .trashBin
            default:
                return .ok
            }
        }
    }
    
    init?(operationType: ElementTypes) {
        switch operationType {
        case .addToFavorites,
             .delete,
             .download,
             .downloadDocument,
             .emptyTrashBin,
             .move,
             .removeFromFavorites,
             .restore,
             .endSharing,
             .leaveSharing,
             .moveToTrashShared,
             .privateShare,
             .rename:
            self = .nonCritical
            
        case .moveToTrash:
            self = .action
            
        default:
            return nil
        }
    }
}

final class SnackbarManager {
    
    private let offset: CGFloat = 16
    
    static let shared = SnackbarManager()
    
    private lazy var router = RouterVC()
    private var currentSnackbar: TTGSnackbar?
    
    init() {
        setupObserving()
    }

    func show(elementType: ElementTypes, relatedItems: [BaseDataSourceItem] = [], handler: VoidHandler? = nil) {
        guard let type = SnackbarType(operationType: elementType),
            let message = elementType.snackbarSuccessMessage(relatedItems: relatedItems) else {
            assertionFailure()
            return
        }
        
        show(type: type, message: message, action: type.action(operationType: elementType), axis: .vertical, handler: handler)
    }
    
    func show(type: SnackbarType, message: String, action: SnackbarAction? = nil, axis: NSLayoutConstraint.Axis = .vertical, handler: VoidHandler? = nil) {
        currentSnackbar?.dismiss()
        currentSnackbar = nil
        
        let actionHandler = { [weak self] in
            self?.currentSnackbar?.dismiss()
            self?.currentSnackbar = nil
            handler?()
        }

        let contentView = SnackbarView.with(type: type,
                                            message: message,
                                            actionTitle: action?.localizedTitle,
                                            axis: axis,
                                            action: actionHandler)
    
        currentSnackbar = createSnackbar(contentView: contentView, duration: type.duration)
        updateBottomMargin(animated: false)
        currentSnackbar?.show()
    }
    
    private func createSnackbar(contentView: SnackbarView, duration: TTGSnackbarDuration) -> TTGSnackbar {
        contentView.widthAnchor.constraint(equalToConstant: Device.winSize.width - offset * 2).activate()
        
        let snackbar = TTGSnackbar(customContentView: contentView, duration: duration)
        snackbar.animationType = .fadeInFadeOut
        snackbar.backgroundColor = ColorConstants.snackbarGray
        snackbar.shouldActivateLeftAndRightMarginOnCustomContentView = true
        snackbar.leftMargin = offset
        snackbar.rightMargin = offset
        snackbar.layer.zPosition = 1000 //need for display over the presented controllers
        return snackbar
    }
}

//MARK: - Tabbar observing

private extension SnackbarManager {
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(hideTabBar), name: .hideTabBar, object: nil)     
        NotificationCenter.default.addObserver(self, selector: #selector(showTabBar), name: .showTabBar, object: nil)
    }

    @objc private func showTabBar() {
        updateBottomMargin(isHiddenTabbar: false, animated: true)
    }
    
    @objc private func hideTabBar() {
        updateBottomMargin(isHiddenTabbar: true, animated: true)
    }
    
    private func updateBottomMargin(isHiddenTabbar: Bool? = nil, animated: Bool) {
        guard let snackbar = currentSnackbar else {
            return
        }

        let bottomMargin: CGFloat
        if router.defaultTopController is PhotoVideoDetailViewController {
            bottomMargin = 80
        } else if let isHiddenTabbar = isHiddenTabbar ?? router.tabBarController?.tabBar.isHidden {
            bottomMargin = isHiddenTabbar ? 16 : 80
        } else {
            bottomMargin = 16
        }
        
        if snackbar.bottomMargin != bottomMargin {
            UIView.animate(withDuration: animated ? NumericConstants.animationDuration : 0) {
                snackbar.bottomMargin = bottomMargin
            }
        }
    }
}
