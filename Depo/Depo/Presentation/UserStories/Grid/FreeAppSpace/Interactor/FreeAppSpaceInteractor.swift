//
//  FreeAppSpaceFreeAppSpaceInteractor.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpaceInteractor: BaseFilesGreedInteractor {
    
    var isDeleteRequestRunning = false
    
    private let fileService = FileService()
    
    func onDeleteSelectedItems(selectedItems: [WrapData]) {
        if (isDeleteRequestRunning) {
            return
        }
        
        isDeleteRequestRunning = true
        let uuids = FreeAppSpace.default.getUIDSForObjects(itemsArray: selectedItems)
        
        fileService.details(uuids: uuids, success: { [weak self] objects in
            if (selectedItems.isEmpty) {
                guard let self_ = self else {
                    return
                }
                if let presenter = self_.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        presenter.goBack()
                    }
                    return
                }
            }
            
            let fileService = WrapItemFileService()
            fileService.deleteLocalFiles(deleteFiles: selectedItems, success: {
                
                guard let self_ = self else {
                   return
                }
                
                if let service = self_.remoteItems as? FreeAppService {
                    service.clear()
                }
                self_.isDeleteRequestRunning = false
                if let presenter = self_.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        presenter.onItemDeleted()
                        if FreeAppSpace.default.getDuplicatesObjects().count == 0 {
                            CardsManager.default.stopOperationWithType(type: .freeAppSpace)
                            CardsManager.default.stopOperationWithType(type: .freeAppSpaceLocalWarning)
                        }
                        presenter.goBack()
                    }
                }
                
            }, fail: { [weak self] error in
                self?.isDeleteRequestRunning = false
                if let presenter = self?.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        presenter.canceled()
                    }
                }
            })
        }, fail: { [weak self] error in
            self?.isDeleteRequestRunning = false
            if let presenter = self?.output as? FreeAppSpacePresenter {
                DispatchQueue.main.async {
                    presenter.canceled()
                }
            }
            UIApplication.showErrorAlert(message: error.description)
        })
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        if let remoteItems = remoteItems as? FreeAppService {
            remoteItems.clear()
        }
        super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
}
