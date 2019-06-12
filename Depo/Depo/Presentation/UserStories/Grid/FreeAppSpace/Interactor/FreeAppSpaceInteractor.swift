//
//  FreeAppSpaceFreeAppSpaceInteractor.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpaceInteractor: BaseFilesGreedInteractor {
    
    var isDeleteRequestRunning = false
    
    private lazy var freeAppSpace = FreeAppSpace.session
    private lazy var wrapFileService = WrapItemFileService()
    
    func onDeleteSelectedItems(selectedItems: [WrapData]) {
        if isDeleteRequestRunning {
            return
        }
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .freeUpSpace)
        isDeleteRequestRunning = true
        
        wrapFileService.deleteLocalFiles(deleteFiles: selectedItems, success: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.isDeleteRequestRunning = false
            
            if let presenter = self.output as? FreeAppSpacePresenter {
                DispatchQueue.main.async {
                    presenter.onItemDeleted(count: selectedItems.count)
                    if FreeAppSpace.session.getDuplicatesObjects().isEmpty {
                        CardsManager.default.stopOperationWithType(type: .freeAppSpace)
                        CardsManager.default.stopOperationWithType(type: .freeAppSpaceLocalWarning)
                    }
                    presenter.goBack()
                }
            }
        }, fail: { [weak self] error in
            guard let `self` = self else {
                return
            }
            
            self.isDeleteRequestRunning = false
            if let presenter = self.output as? FreeAppSpacePresenter {
                DispatchQueue.main.async {
                    presenter.canceled()
                }
            }
        })
    }
    
    override func trackScreen() {
        analyticsManager.logScreen(screen: .freeAppSpace)
        analyticsManager.trackDimentionsEveryClickGA(screen: .freeAppSpace)
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        if let remoteItems = remoteItems as? FreeAppService {
            remoteItems.clear()
        }
        super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
}
