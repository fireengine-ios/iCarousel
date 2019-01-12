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
    typealias StringHandler  = (String) -> ()

    private var instaService = InstagramService()
    
    private var successHandler: ViewControllerHandler?
    private var errorHandler: StringHandler?
    
    private var instagramNickname: String?
    private var hasInstagramLikePermission: Bool?
    
    private let doNotShowAgainKey = "instaPickDoNotShowAgainKey"
    public var doNotShowAgain: Bool
    
    init() {
        doNotShowAgain = UserDefaults.standard.bool(forKey: doNotShowAgainKey)
    }
    
    //Utility Methods(public)
    func getViewController(success: @escaping ViewControllerHandler, error: @escaping StringHandler) {
        successHandler = success
        errorHandler = error
        
        if !doNotShowAgain {
            let group = DispatchGroup()
            
            group.enter()
            getNickname(group: group)
            //checkInstagramAccount(group: group)

            group.enter()
            checkInstagramLikePermission(group: group)
            
            group.notify(queue: DispatchQueue.main) {
                self.configureViewController()
            }
        } else {
            configureViewController()
        }
    }
    
    func stopShowing() {
        UserDefaults.standard.set(true, forKey: doNotShowAgainKey)
    }
    
    //Utility Methods(private)
    ///not shure if it needed
//    private func checkInstagramAccount(group: group) {
//        instaService.socialStatus(success: { [weak self] response in
//            guard let response = response as? SocialStatusResponse,
//                let isConnected: Bool = response.instagram else {
//                    let error = CustomErrors.serverError("An error ocured while getting Instagram status.")
//                    self?.showError(with: error.localizedDescription)
//                    return
//            }
//
//            if isConnected {
//                self?.getNickname(group: group)
//            } else {
//                group.leave()
//            }
//        }) { [weak self] error in
//            self?.showError(with: error.localizedDescription)
//        }
//    }
    
    private func checkInstagramLikePermission(group: DispatchGroup) {
        //TODO: - new api will be soon
        let hasPermission = Bool.random()
        hasInstagramLikePermission = hasPermission
        group.leave()
    }
    
    private func getNickname(group: DispatchGroup) {
        //TODO: - new api will be soon
        let names = ["Fred", "Sam", "Din", "Jack", "Emma", "Susan"]
        instagramNickname = names.randomElement()
        group.leave()
    }
    
    private func configureViewController() {
        guard let successHandler = successHandler else { return }
        //TODO: - add controllers
        let title = "Insta Pick"
        var message: String?
        
        if doNotShowAgain {
            message = "You might to open selection mode for InstaPick Analyze"
        } else if let instagramNickname = instagramNickname {
            message = "You might to open InstaPick PopUp with nickname: \(instagramNickname)"
        } else if let hasPermission = hasInstagramLikePermission, hasPermission {
            message = "You might to open selection mode for InstaPick Analyze"
        }
        
        guard let popUpMessage = message else { return }
        let vc = DarkPopUpController.with(title: title, message: popUpMessage, buttonTitle: "OK!")
        successHandler(vc)
    }
    
    private func showError(with message: String) {
        guard let errorHandler = errorHandler else { return }
        errorHandler(message)
    }
}
