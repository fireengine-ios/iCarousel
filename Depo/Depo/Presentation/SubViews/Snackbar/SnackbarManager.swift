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

final class SnackbarManager {
    
    static let shared = SnackbarManager()
    
    private let duration = TTGSnackbarDuration.middle
    
    private var currentSnackbar: TTGSnackbar?
    
    func show(message: String, action: SnackbarAction?, axis: NSLayoutConstraint.Axis, handler: VoidHandler?) {
        currentSnackbar?.dismiss()
        currentSnackbar = nil
        
        let contentView = SnackbarView.initFromNib()
        
        let actionHandler = { [weak self] in
            self?.currentSnackbar?.dismiss()
            self?.currentSnackbar = nil
            handler?()
        }

        contentView.setup(message: message, actionTitle: action?.localizedTitle.uppercased(), axis: axis, action: actionHandler)
        currentSnackbar = TTGSnackbar(customContentView: contentView, duration: duration)
        currentSnackbar?.animationType = .fadeInFadeOut
        currentSnackbar?.backgroundColor = ColorConstants.snackbarGray
        currentSnackbar?.shouldActivateLeftAndRightMarginOnCustomContentView = true
        currentSnackbar?.shouldDismissOnSwipe = true
        currentSnackbar?.show()
    }
}
