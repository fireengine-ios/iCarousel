//
//  InstaPickRoutingService.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class InstaPickRoutingService {
    typealias ViewControllerHandler  = (UIViewController) -> ()

    private lazy var instaService = InstagramService()
    private lazy var accountService = AccountService()
    private lazy var instapickService: InstapickService = factory.resolve()
    
    private var successHandler: ViewControllerHandler?
    private var errorHandler: FailResponse?
    
    private var instagramNickname: String?
    private var instagramLikePermission: Bool?
    private var instagramStatus: Bool?

    private let doNotShowAgainKey = "instaPickDoNotShowAgainKey"
    private var doNotShowAgain: Bool {
        let userID = SingletonStorage.shared.uniqueUserID
        return UserDefaults.standard.bool(forKey: doNotShowAgainKey + userID)
    }
    
    // MARK: Utility Methods(public)
    func getViewController(isCheckAnalyzesCount: Bool? = false, success: @escaping ViewControllerHandler, error: @escaping FailResponse) {
        successHandler = success
        errorHandler = error
        
        if isCheckAnalyzesCount == true {
            getAnalyzesCount()
        } else {
            prepareToOpenController()
        }
    }
    
    func stopShowing() {
        let userID = SingletonStorage.shared.uniqueUserID
        UserDefaults.standard.set(true, forKey: doNotShowAgainKey + userID)
    }
    
    // MARK: Utility Methods(private)
    private func checkInstagramAccount() {
        instaService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected: Bool = response.instagram else {
                    let error = CustomErrors.serverError("An error occurred while getting Instagram status.")
                    let errorResponse = ErrorResponse.error(error)
                    self?.showError(with: errorResponse)
                    return
            }

            self?.got(status: isConnected, nickname: response.instagramUsername)
        }) { [weak self] error in
            self?.showError(with: error)
        }
    }
    
    private func checkInstagramLikePermission() {
        accountService.getSettingsInfoPermissions { [weak self] response in
            switch response {
            case .success(let result):
                self?.got(likePermission: result.isInstapickAllowed == true)
            case .failed(let error):
                let errorResponse = ErrorResponse.error(error)
                self?.showError(with: errorResponse)
            }
        }
    }
    
    private func got(likePermission: Bool) {
        instagramLikePermission = likePermission
        configureViewController()
    }
    
    private func got(status: Bool, nickname: String?) {
        instagramStatus = status
        if let nickname = nickname, status {
            instagramNickname = nickname
            checkInstagramLikePermission()
        } else {
            configureViewController()
        }
    }
    
    private func configureViewController() {
        if doNotShowAgain {
            didOpenInstaPickSelectionSegmented()
        } else if let hasPermission = instagramLikePermission, hasPermission {
            didOpenInstaPickSelectionSegmented()
        } else {
            didOpenInstaPickPopUp(instaNickname: instagramNickname)
        }
    }
    
    private func getAnalyzesCount() {
        instapickService.getAnalyzesCount { [weak self] result in
            switch result {
            case .success(let analysisCount):
                DispatchQueue.toMain {
                    if analysisCount.left > 0 || analysisCount.isFree {
                        self?.prepareToOpenController()
                    } else {
                        self?.didOpenHistoryPopUp()
                    }
                }
            case .failed(let error):
                let errorResponse = ErrorResponse.error(error)
                self?.showError(with: errorResponse)
            }
        }
    }
    
    private func prepareToOpenController() {
        if doNotShowAgain {
            configureViewController()
        } else {
            checkInstagramAccount()
        }
    }
    
    // MARK: Routing
    private func didOpenInstaPickPopUp(instaNickname: String?) {
        clearInfo()

        guard let successHandler = successHandler else {
            UIApplication.showErrorAlert(message: "Success handler unexpected become nil.")
            return
        }
        
        if let vc = InstapickPopUpController.with(instaNickname: instaNickname) {
            vc.delegate = self
            successHandler(vc)
        }
    }
    
    private func didOpenInstaPickSelectionSegmented() {
        clearInfo()

        guard let successHandler = successHandler else {
            UIApplication.showErrorAlert(message: "Success handler unexpected become nil.")
            return
        }
        
        let controller = InstaPickSelectionSegmentedController.controllerToPresent()
        successHandler(controller)
    }
    
    private func didOpenHistoryPopUp() {
        guard let successHandler = successHandler else {
            UIApplication.showErrorAlert(message: "Success handler unexpected become nil.")
            return
        }
        
        let popup = PopUpController.with(title: TextConstants.analyzeHistoryPopupTitle,
                                         message: TextConstants.analyzeHistoryPopupMessage,
                                         image: .custom(UIImage(named: "popup_info")),
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.instaPickButtonNoAnalysis,
                                         firstAction: {  controller in
                                            controller.close()
                                         },
                                         secondAction: { [weak self] controller in
                                            controller.close {
                                                self?.onPurchase()
                                            }
                                         })
        
        let router = RouterVC()
        successHandler(popup)
        router.presentViewController(controller: popup)
    }
    
    private func onPurchase() {
        //TODO: - Open Purchase Screen
        InstaPickRoutingService.openPremium()
    }
    
    private func clearInfo() {
        instagramNickname = nil
        instagramLikePermission = false
    }
    
    private func showError(with error: ErrorResponse) {
        guard let errorHandler = errorHandler else {
            UIApplication.showErrorAlert(message: "Error handler unexpected become nil.")
            return
        }
        errorHandler(error)
    }
    
}

// MARK: - InstapickPopUpControllerDelegate
extension InstaPickRoutingService: InstapickPopUpControllerDelegate {
    
    func onConnectWithoutInsta() {
        didOpenInstaPickSelectionSegmented()
    }
    
    func onConnectWithInsta() {
        didOpenInstaPickSelectionSegmented()
    }
    
}

// MARK: - Instapick Upgrade
extension InstaPickRoutingService {
    static func openPremium() {
        let router = RouterVC()
        
        let controller = router.premium()
        router.pushViewController(viewController: controller)
    }
}
