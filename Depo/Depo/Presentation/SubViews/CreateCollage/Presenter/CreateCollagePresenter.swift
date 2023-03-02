//
//  CreateCollagePresenter.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollagePresenter: BasePresenter, ForYouModuleInput {

    weak var view: CreateCollageViewInput!
    var interactor: CreateCollageInteractor!
    var router: CreateCollageRouterInput!
    
    private lazy var collageTemplateData: [CollageTemplate] = []
    
    func viewIsReady() {
        interactor.viewIsReady()
        view.showSpinner()
    }
}

extension CreateCollagePresenter: CreateCollageViewOutput {

}

extension CreateCollagePresenter: CreateCollageInteractorOutput {
    func getCollageTemplate(data: [CollageTemplate]) {
        self.collageTemplateData = data
    }
    
    func didFinishedAllRequests() {
        view.hideSpinner()
        view.didFinishedAllRequests()
    }
}
