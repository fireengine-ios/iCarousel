//
//  PhotoPrintPresenter.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintPresenter: BasePresenter, PhotoPrintModuleInput {

    weak var view: PhotoPrintViewInput!
    var interactor: PhotoPrintInteractor!
    var router: PhotoPrintRouterInput!
    
    func viewIsReady() {
        
    }
}

extension PhotoPrintPresenter: PhotoPrintViewOutput {
    func getSectionsCountAndName() {
        print("aaa")
    }
}

extension PhotoPrintPresenter: PhotoPrintInteractorOutput {
    
    func didFinishedAllRequests() {
        view.hideSpinner()
        view.didFinishedAllRequests()
    }
}
