//
//  MoreFilesActionsPresenter.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class MoreFilesActionsPresenter: BasePresenter, MoreFilesActionsModuleInput, MoreFilesActionsInteractorOutput {
    var interactor: MoreFilesActionsInteractorInput!
    weak var basePassingPresenter: BaseItemInputPassingProtocol? //do I need it here?
    
    // MARK: - Interactor output
    
    func operationFinished(type: ElementTypes) {
        completeAsyncOperationEnableScreen()
        basePassingPresenter?.operationFinished(withType: type, response: nil)
    }
    
    func operationFailed(type: ElementTypes, message: String) {
        completeAsyncOperationEnableScreen()
        basePassingPresenter?.operationFailed(withType: type)
        if type != .deleteDeviceOriginal {
            UIApplication.showErrorAlert(message: message)
        }
    }
    
    func operationStarted(type: ElementTypes) {
        startAsyncOperationDisableScreen()
    }
    
    func dismiss(animated: Bool) {} /// overriding
    
    func showWrongFolderPopup() {
        basePassingPresenter?.showAlert(with: TextConstants.errorSameDestinationFolder)
    }
    
    // MARK: - Base presenter
    
    override func outputView() -> Waiting? {
        return RouterVC().rootViewController
    }
}
