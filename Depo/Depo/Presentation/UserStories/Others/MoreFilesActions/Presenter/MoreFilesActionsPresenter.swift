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
        operationFailed(with: type)
        if type != .deleteDeviceOriginal {
            UIApplication.showErrorAlert(message: message)
        }
    }
    
    func successPopupClosed() {
        basePassingPresenter?.successPopupClosed()
    }
    
    private func operationFailed(with type: ElementTypes) {
        completeAsyncOperationEnableScreen()
        basePassingPresenter?.operationFailed(withType: type)
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
    
    func showOutOfSpaceAlert(failedType type: ElementTypes) {
        operationFailed(with: type)
        
        let controller = PopUpController.with(title: TextConstants.syncOutOfSpaceAlertTitle,
                                              message: TextConstants.syncOutOfSpaceAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.syncOutOfSpaceAlertCancel,
                                              secondButtonTitle: TextConstants.upgrade,
                                              secondAction: { vc in
                                                vc.close(completion: {
                                                    let router = RouterVC()
                                                    if router.navigationController?.presentedViewController != nil {
                                                        router.pushOnPresentedView(viewController: router.packages)
                                                    } else {
                                                        router.pushViewController(viewController: router.packages)
                                                    }
                                                })
        })
        
        DispatchQueue.toMain {
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
        }
    }
}
