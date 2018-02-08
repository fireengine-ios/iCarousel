//
//  BasePresentor.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/29/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol BaseAsyncOperationInteractorOutput {
    
    func outputView() -> Waiting?
    
    func startAsyncOperation()
    
    func startAsyncOperationDisableScreen()
    
    func startCancelableAsync(cancel: @escaping () -> Void)
    
    func compliteAsyncOperationEnableScreen(errorMessage: String?)
    
    func compliteAsyncOperationEnableScreen()
    
    func asyncOperationSucces()
    
    func asyncOperationFail(errorMessage: String?)

}

class BasePresenter: BaseAsyncOperationInteractorOutput {
    
    func startCancelableAsync(cancel: @escaping () -> Void) {
        outputView()?.showSpinerWithCancelClosure {
            UploadService.default.cancelSyncToUseOperations()
            cancel()
        }
    }
    
    func outputView() -> Waiting? {
        return nil
    }
    
    func startAsyncOperation() {
        outputView()?.showSpiner()
    }
    
    func startAsyncOperation(progress: Int) {
        outputView()?.showSpiner()
    }
    
    func startAsyncOperationDisableScreen() {
        outputView()?.showSpinerIncludeNavigatinBar()
    }
    
    func compliteAsyncOperationEnableScreen(errorMessage: String?) {
        outputView()?.hideSpinerIncludeNavigatinBar()
        showMessage(errorMessage: errorMessage)
    }
    
    func compliteAsyncOperationEnableScreen() {
        outputView()?.hideSpinerIncludeNavigatinBar()
    }
    
    func asyncOperationSucces() {
        outputView()?.hideSpiner()
    }
    
    func asyncOperationFail(errorMessage: String?) {
        asyncOperationSucces()
        showMessage(errorMessage: errorMessage)
    }
    
    private func showMessage(errorMessage: String?) {
        if let message = errorMessage{
            UIApplication.showErrorAlert(message: message)
        }
    }
}
