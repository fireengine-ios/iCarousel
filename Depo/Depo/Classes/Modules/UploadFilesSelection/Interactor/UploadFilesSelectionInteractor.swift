//
//  UploadFilesSelectionUploadFilesSelectionInteractor.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionInteractor: BaseFilesGreedInteractor {


    func uploadItems(items: [BaseDataSourceItem]){
        
        let uploadItem = items as! [WrapData]
        UploadService.default.uploadFileList(items: uploadItem,
                                             uploadType: .fromHomePage,
                                             uploadStategy: .WithoutConflictControl,
                                             uploadTo: .MOBILE_UPLOAD,
                                             folder: "",
                                             success: { [weak self] in
                                                self?.compliteAsyncOpertion()
        },
                                             fail: { [weak self]  (error) in
                                                self?.compliteAsyncOpertion()
        })
            
    }
    
    private func compliteAsyncOpertion() {
        
        DispatchQueue.main.async {
            self.output.asyncOperationSucces()
        }
    }
    
}

