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
    
    func onlyOfficeFilterSuccess(documentType: OnlyOfficeFilterType, items: [WrapData]) {
        basePassingPresenter?.onlyOfficeFilterSuccess(documentType: documentType, items: items)
    }
    
    func operationFinished(type: ElementTypes) {
        completeAsyncOperationEnableScreen()
        basePassingPresenter?.operationFinished(withType: type, response: nil)
    }
    
    func operationFailed(type: ElementTypes, message: String) {
        operationFailed(with: type)
        if type != .deleteDeviceOriginal {
            UIApplication.showErrorAlert(message: message)
        }
    }
    
    func successPopupClosed() {
        basePassingPresenter?.successPopupClosed()
    }
    
    func successPopupWillAppear() {
        basePassingPresenter?.successPopupWillAppear()
    }
    
    private func operationFailed(with type: ElementTypes) {
        completeAsyncOperationEnableScreen()
        basePassingPresenter?.operationFailed(withType: type)
    }
    
    func operationStarted(type: ElementTypes) {
        basePassingPresenter?.stopModeSelected()
        startAsyncOperationDisableScreen()
    }
    
    func operationCancelled(type: ElementTypes) {
        completeAsyncOperationEnableScreen()
    }
    
    func dismiss(animated: Bool) {} /// overriding
    
    func showWrongFolderPopup() {
        basePassingPresenter?.showAlert(with: TextConstants.errorSameDestinationFolder)
    }
    
    func stopSelectionMode() {
        basePassingPresenter?.stopModeSelected()
    }
    
    // MARK: - Base presenter
    
    override func outputView() -> Waiting? {
        return RouterVC().rootViewController
    }
    
    func showOutOfSpaceAlert(failedType type: ElementTypes) {
        operationFailed(with: type)
        RouterVC().showFullQuotaPopUp()
    }
}
