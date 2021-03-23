//
//  PrivateShareSharedItemThreeDotsManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 18.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


final class PrivateShareSharedItemThreeDotsManager {
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func showActions(for privateShareType: PrivateShareType, item: WrapData, sender: Any?) {
        let types = innerFolderActionTypes(for: privateShareType.rootType, item:  item)
        alert.show(with: types, for: [item], presentedBy: sender, onSourceView: nil, viewController: nil)
    }
    
    func handleAction(type: ElementTypes, item: Item, sender: Any?) {
        alert.handleAction(type: type, items: [item], sender: sender)
    }
    
    private func innerFolderActionTypes(for rootType: PrivateShareType, item: WrapData) -> [ElementTypes] {
        switch rootType { 
            case .byMe, .myDisk, .withMe, .sharedArea:
                return ElementTypes.specifiedMoreActionTypes(for: item.status, item: item)

            case .trashBin:
                return ElementTypes.specifiedMoreActionTypesForTrashBin(for: item.status, item: item)
            case .innerFolder:
                assertionFailure("should not be the case")
                return []
        }
        
    }
}
