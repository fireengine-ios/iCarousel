//
//  FreeAppSpaceFreeAppSpaceInteractor.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpaceInteractor: BaseFilesGreedInteractor {
    
    func onDeleteSelectedItems(selectedItems: [BaseDataSourceItem]){
        let uuids = FreeAppSpace.default.getServerUIDSForLocalitem(localItemsArray: selectedItems)
        
        FileService().details(uuids: uuids, success: { (objects) in
            print(objects.count)
        }) { (error) in
            
        }
    }
    
}
