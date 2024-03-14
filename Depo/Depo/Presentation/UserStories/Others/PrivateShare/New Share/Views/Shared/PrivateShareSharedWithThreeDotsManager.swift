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
            case .byMe:
            alert.show(with: [.select, .officeFilterAll, .officeFilterPdf, .officeFilterWord, .officeFilterCell, .officeFilterSlide], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .withMe:
            alert.show(with: [.officeFilterAll, .officeFilterPdf, .officeFilterWord, .officeFilterCell, .officeFilterSlide], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .innerFolder:
                //TODO:
            alert.show(with: [.select, .officeFilterAll, .officeFilterPdf, .officeFilterWord, .officeFilterCell, .officeFilterSlide], for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
        }
    }
    
    func showActions(for privateShareType: PrivateShareType, selectedItems: [WrapData], sender: Any?) {
        switch privateShareType {
            case .byMe:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .withMe:
                return
                
            case .innerFolder:
                //TODO:
                let types = actionTypes(for: selectedItems)
                alert.show(with: types, for: selectedItems, presentedBy: sender, onSourceView: nil, viewController: nil)
        }
    }
    
    private func actionTypes(for items: [WrapData]) -> [ElementTypes] {
        //TODO:
        return []
    }
}
