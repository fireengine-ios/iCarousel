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
    typealias ErrorHandler  = (LocalizedError) -> ()

    private var instaService = InstagramService()
    
    private var successHandler: ViewControllerHandler?
    private var errorHandler: ErrorHandler?
    
    private var instagramNickname: String?
    private var instagramLikePermission: Bool?
    private var instagramStatus: Bool?

    private let doNotShowAgainKey = "instaPickDoNotShowAgainKey"
    public var doNotShowAgain: Bool
    
    init() {
        doNotShowAgain = UserDefaults.standard.bool(forKey: doNotShowAgainKey)
    }
    
    //Utility Methods(public)
    func getViewController(success: @escaping ViewControllerHandler, error: @escaping ErrorHandler) {
        successHandler = success
        errorHandler = error
        
        if !doNotShowAgain {
            checkInstagramAccount()
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
                    let error = CustomErrors.serverError("An error ocured while getting Instagram status.")
                    self?.showError(with: error)
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
            let error = CustomErrors.serverError("An error occured while getting nickName from server.")
            showError(with: error)
        }
    }
    
    private func got(likePermission: Bool) {
        instagramLikePermission = likePermission
        if likePermission {
            configureViewController()
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
        guard let successHandler = successHandler else { return }
        //TODO: - add controllers
        let title = "Insta Pick"
        var message: String = "You might to open InstaPick PopUp"
        
        if doNotShowAgain {
            message = "You might to open selection mode for InstaPick Analyze"
        } else if let instagramNickname = instagramNickname {
            message = "You might to open InstaPick PopUp with nickname: \(instagramNickname)"
        } else if let hasPermission = instagramLikePermission, hasPermission {
            message = "You might to open selection mode for InstaPick Analyze"
        }
        
        let vc = DarkPopUpController.with(title: title, message: message, buttonTitle: "OK!")
        successHandler(vc)
    }
    
    private func showError(with error: LocalizedError) {
        guard let errorHandler = errorHandler else { return }
        errorHandler(error)
    }
}
