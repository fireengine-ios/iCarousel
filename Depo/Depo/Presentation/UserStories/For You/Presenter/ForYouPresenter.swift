//
//  ForYouPresenter.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ForYouPresenter: ForYouModuleInput, ForYouInteractorOutput {
    weak var view: ForYouViewInput!
    var interactor: ForYouInteractorInput!
    var router: ForYouRouterInput!
}

extension ForYouPresenter: ForYouViewOutput {
    func onSeeAllButton(for view: ForYouViewEnum) {
        router.navigateToSeeAll(for: view)
    }
    
    func checkFIRisAllowed() {
        interactor.getFIRStatus { settings in
            guard let isFaceImageAllowed = settings.isFaceImageAllowed else { return }
            self.view.getFIRResponse(isAllowed: isFaceImageAllowed)
        } fail: { error in
            print(error.localizedDescription)
        }
    }
    
    func onFaceImageButton() {
        router.navigateToFaceImage()
    }
}
