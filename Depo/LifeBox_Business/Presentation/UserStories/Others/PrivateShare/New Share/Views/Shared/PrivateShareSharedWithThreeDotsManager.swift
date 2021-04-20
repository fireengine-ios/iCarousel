//
//  PrivateShareSharedWithThreeDotsManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 18.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class PrivateShareSharedWithThreeDotsManager {
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func showActions(for privateShareType: PrivateShareType, sender: Any?) {
        switch privateShareType {
            case .myDisk:
                alert.show(with: [.select], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .byMe:
                alert.show(with: [.select], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .withMe:
                return
                
            case .innerFolder:
                alert.show(with: [.select], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .sharedArea:
                alert.show(with: [.select], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .trashBin:
                alert.show(with: [.select], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .search:
                alert.show(with: [.select], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
        }
    }
    
    func showActions(for privateShareType: PrivateShareType, selectedItems: [WrapData], sender: Any?) {
        switch privateShareType {
            case .myDisk:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .byMe:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .withMe:
                return
                
            case .innerFolder:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .sharedArea:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .trashBin:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .search:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
        }
    }
    
    private func actionTypes(for items: [WrapData]) -> [ElementTypes] {
        return []
    }
}
