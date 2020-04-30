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
    case retry
    case undo
    
    var localizedTitle: String {
        switch self {
        case .ok:
            return TextConstants.snackbarOk
        case .retry:
            return TextConstants.snackbarRetry
        case .undo:
            return TextConstants.snackbarUndo
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
            return .forever
        }
    }
    
    var action: SnackbarAction? {
        switch self {
        case .nonCritical:
            return nil
        case .critical:
            return .ok
        case .action:
            return .ok
        }
    }
    
    init?(operationType: ElementTypes) {
        switch operationType {
        case .addToAlbum,
             .addToFavorites,
             .delete,
             .download,
             .edit,
             .emptyTrashBin,
             .move,
             .removeAlbum,
             .removeFromFavorites,
             .restore,
             .unhide:
            self = .nonCritical
            
        case .hide,
             .moveToTrash:
            self = .action
            
        default:
            return nil
        }
    }
}

final class SnackbarManager {
    
    static let shared = SnackbarManager()
    
    private lazy var router = RouterVC()
    private var currentSnackbar: TTGSnackbar?
    
    init() {
        setupObserving()
    }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideTabBar),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationHideTabBar),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showTabBar),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar),
                                               object: nil)
    }
    
    func show(elementType: ElementTypes, relatedItems: [BaseDataSourceItem] = [], itemsType: DivorseItems? = nil, handler: VoidHandler? = nil) {
        guard let type = SnackbarType(operationType: elementType),
            let message = elementType.snackbarSuccessMessage(relatedItems: relatedItems, divorseItems: itemsType) else {
            assertionFailure()
            return
        }
        
        show(type: type, message: message, action: type.action, axis: .vertical, handler: handler)
    }
    
    func show(type: SnackbarType, message: String, action: SnackbarAction? = nil, axis: NSLayoutConstraint.Axis = .vertical, handler: VoidHandler? = nil) {
        currentSnackbar?.dismiss()
        currentSnackbar = nil
        
        let actionHandler = { [weak self] in
            self?.currentSnackbar?.dismiss()
            self?.currentSnackbar = nil
            handler?()
        }

        currentSnackbar = createSnackbar(duration: type.duration)
        let contentView = currentSnackbar?.customContentView as? SnackbarView
        contentView?.setup(type: type,
                           message: message,
                           actionTitle: action?.localizedTitle.uppercased(),
                           axis: axis,
                           action: actionHandler)
        
        updateBottomMargin(animated: false)
        currentSnackbar?.show()
    }
    
    private func createSnackbar(duration: TTGSnackbarDuration) -> TTGSnackbar {
        let contentView = SnackbarView.initFromNib()
        let snackbar = TTGSnackbar(customContentView: contentView, duration: duration)
        snackbar.animationType = .fadeInFadeOut
        snackbar.backgroundColor = ColorConstants.snackbarGray
        snackbar.shouldActivateLeftAndRightMarginOnCustomContentView = true
        snackbar.leftMargin = 16
        snackbar.rightMargin = 16
        return snackbar
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
    
    func bringToFrontCurrentSnackbar() {
        guard let snackbar = currentSnackbar else {
            return
        }
        
        snackbar.superview?.bringSubview(toFront: snackbar)
    }
}
