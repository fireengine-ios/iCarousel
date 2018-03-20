//
//  MoreFilesActionsInteractorOutput.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol MoreFilesActionsInteractorOutput: class, BaseAsyncOperationInteractorOutput {
    func operationFinished(type: ElementTypes)//add type?
    func operationFailed(type: ElementTypes, message: String)
    func operationStarted(type: ElementTypes)
    func showWrongFolderPopup()
    
    func dismiss(animated: Bool)
}
