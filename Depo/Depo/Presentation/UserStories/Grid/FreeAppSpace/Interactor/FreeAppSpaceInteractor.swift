//
//  FreeAppSpaceFreeAppSpaceInteractor.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpaceInteractor: BaseFilesGreedInteractor {
    
    func onDeleteSelectedItems(selectedItems: [WrapData]) {
        let uuids = FreeAppSpace.default.getServerUIDSForLocalitem(localItemsArray: selectedItems)
        
        FileService().details(uuids: uuids, success: { [weak self] (objects) in
            //let localFilesForDelete = FreeAppSpace.default.getLocalFiesComaredWithServerObjects(serverObjects: objects, localObjects: selectedItems)
            
            let array = FreeAppSpace.default.getLocalFiesComaredWithServerObjects(serverObjects: objects, localObjects: selectedItems)
            
            let fileService = WrapItemFileService()
            fileService.deleteLocalFiles(deleteFiles: array, success: {
                
                FreeAppSpace.default.deleteDeletedLocalPhotos(deletedPhotos: array)
                
                guard let self_ = self else{
                   return
                }
                
                if let service = self_.remoteItems as? FreeAppService {
                    service.clear()
                }
                if let presenter = self_.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        presenter.onItemDeleted()
                        presenter.goBack()
                    }
                }
                
            }, fail: { [weak self] error in
                if let presenter = self?.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        presenter.reloadData()
                    }
                }
            })
        }) { (error) in
            
        }
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        if let remoteItems = remoteItems as? FreeAppService {
            remoteItems.clear()
        }
        super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
}
