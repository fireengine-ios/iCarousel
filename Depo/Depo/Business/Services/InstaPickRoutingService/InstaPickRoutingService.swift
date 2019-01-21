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

    private var instaService = InstagramService()
    
    private var successHandler: ViewControllerHandler?
    private var errorHandler: FailResponse?
    
    private var instagramNickname: String?
    private var instagramLikePermission: Bool?
    private var instagramStatus: Bool?

    private let doNotShowAgainKey = "instaPickDoNotShowAgainKey"
    private var doNotShowAgain: Bool {
        return UserDefaults.standard.bool(forKey: doNotShowAgainKey)
    }
    
    //Utility Methods(public)
    func getViewController(success: @escaping ViewControllerHandler, error: @escaping FailResponse) {
        successHandler = success
        errorHandler = error
        
        if !doNotShowAgain {
            checkInstagramLikePermission()
        } else {
            configureViewController()
        }
    }
    
    func stopShowing() {
        UserDefaults.standard.set(true, forKey: doNotShowAgainKey)
    }
    
    //Utility Methods(private)
    private func checkInstagramAccount() {
        instaService.socialStatus(success: { [weak self] response in
            guard let response = response as? SocialStatusResponse,
                let isConnected: Bool = response.instagram else {
                    let error = CustomErrors.serverError("An error occurred while getting Instagram status.")
                    let errorResponse = ErrorResponse.error(error)
                    self?.showError(with: errorResponse)
                    return
            }

            self?.got(status: isConnected)
        }) { [weak self] error in
            self?.showError(with: error)
        }
    }
    
    private func checkInstagramLikePermission() {
        //TODO: - new api will be soon
        let hasPermission = Bool.random()
        got(likePermission: hasPermission)
    }
    
    private func getNickname() {
        //TODO: - new api will be soon
        let names = ["Fred", "Sam", "Din", "Jack", "Emma", "Susan"]
        if let name = names.randomElement() {
            got(nickName: name)
        } else {
            let error = CustomErrors.serverError("An error occurred while getting nickname.")
            let errorResponse = ErrorResponse.error(error)
            showError(with: errorResponse)
        }
    }
    
    private func got(likePermission: Bool) {
        instagramLikePermission = likePermission
        if likePermission {
            configureViewController()
        } else {
            checkInstagramAccount()
        }
    }
    
    private func got(status: Bool) {
        instagramStatus = status
        if status {
            getNickname()
        } else {
            configureViewController()
        }
    }
    
    private func got(nickName: String) {
        instagramNickname = nickName
        configureViewController()
    }
    
    private func configureViewController() {
        if doNotShowAgain {
            didOpenInstaPickSelectionSegmented()
        } else if let instagramNickname = instagramNickname {
            didOpenInstaPickPopUp(instaNickname: instagramNickname)
        } else if let hasPermission = instagramLikePermission, hasPermission {
            didOpenInstaPickSelectionSegmented()
        } else {
            didOpenInstaPickPopUp()
        }
    }
    
    private func didOpenInstaPickPopUp(instaNickname: String? = nil) {
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
        guard let successHandler = successHandler else {
            UIApplication.showErrorAlert(message: "Success handler unexpected become nil.")
            return
        }
        
        let router = RouterVC()
        let controller = InstaPickSelectionSegmentedController.controllerToPresent()
        successHandler(controller)
        router.presentViewController(controller: controller)
    }
    
    private func showError(with error: ErrorResponse) {
        guard let errorHandler = errorHandler else {
            UIApplication.showErrorAlert(message: "Error handler unexpected become nil.")
            return
        }
        errorHandler(error)
    }
}

extension InstaPickRoutingService: InstapickPopUpControllerDelegate {
    
    func onConnectWithoutInsta() {
        didOpenInstaPickSelectionSegmented()
    }
    
    func onConnectWithInsta() {
        didOpenInstaPickSelectionSegmented()
    }
    
}
