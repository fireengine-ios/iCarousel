//
//  UploadFilesSelectionUploadFilesSelectionInteractor.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionInteractor: BaseFilesGreedInteractor {

    var uploadOutput: UploadFilesSelectionInteractorOutput?
    var rootUIID: String?
    
    func addToUploadOnDemandItems(items: [BaseDataSourceItem]){
        let uploadItems = items as! [WrapData]
        UploadService.default.uploadOnDemandFileList(items: uploadItems,
                                                     uploadType: .autoSync,
                                                     uploadStategy: .WithoutConflictControl,
                                                     uploadTo: .MOBILE_UPLOAD,
                                                     folder: rootUIID ?? "")
    }
}

