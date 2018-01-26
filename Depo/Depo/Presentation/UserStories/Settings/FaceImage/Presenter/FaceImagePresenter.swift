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
}

// MARK: - FaceImageInteractorOutput

extension FaceImagePresenter: FaceImageInteractorOutput {
    func didFaceImageStatus(_ isFaceImageAllowed: Bool) {
        view?.stopActivityIndicator()
        view?.showFaceImageStatus(isFaceImageAllowed)
    }
    
    func operationFailed() {
        view?.stopActivityIndicator()
    }
}

