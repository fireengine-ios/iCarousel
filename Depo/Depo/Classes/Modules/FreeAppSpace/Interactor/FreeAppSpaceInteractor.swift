//
//  FreeAppSpaceFreeAppSpaceInteractor.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpaceInteractor: BaseFilesGreedInteractor {
    
    func onDeleteSelectedItems(selectedItems: [WrapData]){
        let uuids = FreeAppSpace.default.getServerUIDSForLocalitem(localItemsArray: selectedItems)
        
        FileService().details(uuids: uuids, success: {[weak self] (objects) in
            let localFilesForDelete = FreeAppSpace.default.getLocalFiesComaredWithServerObjects(serverObjects: objects, localObjects: selectedItems)
            print(localFilesForDelete.count)
            
            let array = FreeAppSpace.default.getLocalFiesComaredWithServerObjects(serverObjects: objects, localObjects: selectedItems)
            
            let fileService = WrapItemFileService()
            fileService.delete(deleteFiles: array, success: {
                
                FreeAppSpace.default.deleteDeletedLocalPhotos(deletedPhotos: array)
                
                guard let self_ = self else{
                   return
                }
                
                if let service = self_.remoteItems as? FreeAppService{
                    service.clear()
                }
                if let presenter = self_.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        presenter.onItemDeleted()
                    }
                    if FreeAppSpace.default.isDuplicatesNotAvailable() {
                        DispatchQueue.main.async {
                            WrapItemOperatonManager.default.stopOperationWithType(type: .freeAppSpace)
                            WrapItemOperatonManager.default.stopOperationWithType(type: .freeAppSpaceWarning)
                            presenter.goBack()
                        }
                    }else{
                        presenter.reloadData()
                    }
                }
                
            }, fail: { (error) in
                guard let self_ = self else{
                    return
                }
                
                if let presenter = self_.output as? FreeAppSpacePresenter {
                    presenter.reloadData()
                }
            })
        }) { (error) in
            
        }
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
}
