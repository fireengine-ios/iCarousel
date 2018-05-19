//
//  FaceImagePresenter.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImagePresenter: BasePresenter {
    
    weak var view: FaceImageViewInput?
    var interactor: FaceImageInteractorInput!
    var router: FaceImageRouterInput!
}

// MARK: - FaceImageViewOutput

extension FaceImagePresenter: FaceImageViewOutput {
    func viewIsReady() {
        view?.startActivityIndicator()
        
        interactor.getFaceImageStatus()
    }
    
    func changeFaceImageStatus(_ isAllowed: Bool) {
        view?.startActivityIndicator()
        
        interactor.changeFaceImageStatus(isAllowed)
        
        if isAllowed {
            router.showPopUp()
        }
        
        MenloworksTagsService.shared.faceImageRecognition(isOn: isAllowed)
    }
}

// MARK: - FaceImageInteractorOutput

extension FaceImagePresenter: FaceImageInteractorOutput {
    func operationFinished() {
        view?.stopActivityIndicator()
    }
    
    func showError(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
    
    func didFaceImageStatus(_ isFaceImageAllowed: Bool) {
        view?.showFaceImageStatus(isFaceImageAllowed)
    }

    func failedChangeFaceImageStatus(error: String) {
        UIApplication.showErrorAlert(message: error)
        
        view?.stopActivityIndicator()
        view?.showfailedChangeFaceImageStatus()
    }
}
