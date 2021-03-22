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
    func onThreeDotsManagerRestore(item: Item?)
    func onThreeDotsManagerDelete(item: Item?)
    func onThreeDotsManagerInfo(item: Item?)
    func onThreeDotsManagerDeleteAll()
}

final class TrashBinThreeDotMenuManager {
    
    private weak var delegate: TrashBinThreeDotMenuManagerDelegate!
    
    init(delegate: TrashBinThreeDotMenuManagerDelegate) {
        self.delegate = delegate
    }
    
    func showActions(isSelectingMode: Bool, sender: UIBarButtonItem) {
        if isSelectingMode {
            showAlertSheet(with: ElementTypes.trashState, item: nil, sender: sender)
        } else {
            showAlertSheet(with: [.select, .emptyTrashBin], item: nil, sender: sender)
        }
    }
    
    func showActions(item: Item, sender: Any) {
        let types = [.info] + ElementTypes.trashState
        showAlertSheet(with: types, item: item, sender: sender)
    }
    
    func handleAction(type: ActionType, item: Item) {
        switch type {
        case .elementType(let elementType):
            handleAction(type: elementType, item: item)
        case .shareType:
            break
        }
    }

    private func showAlertSheet(with types: [ElementTypes], item: Item?, sender: Any) {
        guard let controller = RouterVC().getViewControllerForPresent() else {
            return
        }
        
        let view = controller.view
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        types.forEach { type in
            let action: UIAlertAction?
            switch type {
            case .restore, .select, .delete, .emptyTrashBin, .info:
                action = UIAlertAction(title: type.actionTitle, style: .default, handler: { [weak self] _ in
                    self?.handleAction(type: type, item: item)
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
        
        if let barButtonItem = sender as? UIBarButtonItem {
            actionSheetVC.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let moreButton = sender as? UIButton {
            let moreButtonRect = moreButton.convert(moreButton.bounds, to: controller.view)
            let rect = CGRect(x: moreButtonRect.midX, y: moreButtonRect.minY - 10, width: 10, height: 50)
            actionSheetVC.popoverPresentationController?.sourceRect = rect
        }
        
        actionSheetVC.popoverPresentationController?.permittedArrowDirections = .up
        
        controller.present(actionSheetVC, animated: true)
    }
    
    private func handleAction(type: ElementTypes, item: Item?) {
        switch type {
        case .restore:
            delegate.onThreeDotsManagerRestore(item: item)
        case .select:
            delegate.onThreeDotsManagerSelect()
        case .delete:
            delegate.onThreeDotsManagerDelete(item: item)
        case .emptyTrashBin:
            delegate.onThreeDotsManagerDeleteAll()
        case .info:
            delegate.onThreeDotsManagerInfo(item: item)
        default:
            break
        }
    }
}
