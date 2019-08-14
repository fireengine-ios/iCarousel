//
//  SpotifyThreeDotMenuManager.swift
//  Depo
//
//  Created by Andrei Novikau on 8/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol SpotifyThreeDotMenuManagerDelegate: class {
    func onThreeDotsManagerSelect()
    func onThreeDotsManagerDelete()
}

final class SpotifyThreeDotMenuManager {
    
    private weak var delegate: SpotifyThreeDotMenuManagerDelegate!
    
    init(delegate: SpotifyThreeDotMenuManagerDelegate) {
        self.delegate = delegate
    }
    
    func showActions(isSelectingMode: Bool, sender: UIBarButtonItem) {
        if isSelectingMode {
            showAlertSheet(with: [.delete], sender: sender)
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
