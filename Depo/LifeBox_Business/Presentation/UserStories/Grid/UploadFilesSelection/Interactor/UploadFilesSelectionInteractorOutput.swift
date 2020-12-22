//
//  UploadFilesSelectionUploadFilesSelectionInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UploadFilesSelectionInteractorOutput: class {

    func networkOperationStopped()
    
    func addToUploadStarted()

    func addToUploadSuccessed()
    
    func addToUploadFailedWith(errorMessage: String)
    
    func newLocalItemsReceived(newItems: [BaseDataSourceItem])
    
}
