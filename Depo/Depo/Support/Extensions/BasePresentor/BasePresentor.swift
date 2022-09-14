//
//  BasePresentor.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/29/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol BaseAsyncOperationInteractorOutput: AnyObject {
    
    func outputView() -> Waiting?
    
    func startAsyncOperation()
    
    func startAsyncOperationDisableScreen()
    
    func startCancelableAsync(cancel: @escaping VoidHandler)
    func startCancelableAsync(with text: String, cancel: @escaping VoidHandler)
    
    func completeAsyncOperationEnableScreen(errorMessage: String?)
    
    func completeAsyncOperationEnableScreen()
    
    func asyncOperationSuccess()
    
    func asyncOperationFail(errorMessage: String?)
    
    func confirmationPopUpCancelTapped()
}

extension BaseAsyncOperationInteractorOutput {
    func confirmationPopUpCancelTapped() {}
}

class BasePresenter: NSObject, BaseAsyncOperationInteractorOutput {
    
    func startCancelableAsync(cancel: @escaping VoidHandler) {
        DispatchQueue.toMain {
            self.outputView()?.showSpinerWithCancelClosure(cancel)
        }
    }
    
    func startCancelableAsync(with text: String, cancel: @escaping VoidHandler) {
        outputView()?.showFullscreenHUD(with: text, and: cancel)
    }
    
    func outputView() -> Waiting? {
        return nil
    }
    
    func startAsyncOperation() {
        outputView()?.showSpinner()
    }
    
    func startAsyncOperation(progress: Int) {
        outputView()?.showSpinner()
    }
    
    func startAsyncOperationDisableScreen() {
        outputView()?.showSpinnerIncludeNavigationBar()
    }
    
    func completeAsyncOperationEnableScreen(errorMessage: String?) {
        outputView()?.hideSpinnerIncludeNavigationBar()
        showMessage(errorMessage: errorMessage)
    }
    
    func completeAsyncOperationEnableScreen() {
        outputView()?.hideSpinnerIncludeNavigationBar()
    }
    
    func asyncOperationSuccess() {
        outputView()?.hideSpinner()
    }
    
    func asyncOperationFail(errorMessage: String?) {
        asyncOperationSuccess()
        showMessage(errorMessage: errorMessage)
    }
    
    func asyncOperationFail() {
        outputView()?.hideSpinner()
    }
    
    private func showMessage(errorMessage: String?) {
        if let message = errorMessage {
            UIApplication.showCustomAlert(title: TextConstants.errorAlert,
                                          message: message,
                                          image: .custom(Image.forgetPassPopupLock.image),
                                          buttonTitle: TextConstants.ok)
        }
    }
}
