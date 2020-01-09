//
//  TrashBinThreeDotMenuManager.swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol TrashBinThreeDotMenuManagerDelegate: class {
    func onThreeDotsManagerSelect()
    func onThreeDotsManagerRestore()
    func onThreeDotsManagerDelete()
}

final class TrashBinThreeDotMenuManager {
    
    private weak var delegate: TrashBinThreeDotMenuManagerDelegate!
    
    init(delegate: TrashBinThreeDotMenuManagerDelegate) {
        self.delegate = delegate
    }
    
    func showActions(isSelectingMode: Bool, sender: UIBarButtonItem) {
        if isSelectingMode {
            showAlertSheet(with: [.unhide, .delete], sender: sender)
        } else {
            showAlertSheet(with: [.select], sender: sender)
        }
    }

    private func showAlertSheet(with types: [ElementTypes], sender: UIBarButtonItem) {
        guard let controller = RouterVC().getViewControllerForPresent() else {
            return
        }
        
        let view = controller.view
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        types.forEach { type in
            let action: UIAlertAction?
            switch type {
            case .unhide: //TODO: change to restore
                action = UIAlertAction(title: TextConstants.actionSheetUnhide, style: .default, handler: { [weak self] _ in
                    self?.delegate.onThreeDotsManagerRestore()
                })
            case .select:
                action = UIAlertAction(title: TextConstants.actionSheetSelect, style: .default, handler: { [weak self] _ in
                    self?.delegate.onThreeDotsManagerSelect()
                })
            case .delete:
                action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { [weak self] _ in
                    self?.delegate.onThreeDotsManagerDelete()
                })
            default:
                assertionFailure("unowned action")
                action = nil
            }
            
            if let action = action {
                actionSheetVC.addAction(action)
            }
        }
        
        let cancelAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel)
        actionSheetVC.addAction(cancelAction)
        
        actionSheetVC.view.tintColor = UIColor.black
        actionSheetVC.popoverPresentationController?.sourceView = view
        actionSheetVC.popoverPresentationController?.barButtonItem = sender
        actionSheetVC.popoverPresentationController?.permittedArrowDirections = .up
        
        controller.present(actionSheetVC, animated: true)
    }
}
