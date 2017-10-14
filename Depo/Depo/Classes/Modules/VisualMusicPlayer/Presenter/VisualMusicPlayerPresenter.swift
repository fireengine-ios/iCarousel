//
//  VisualMusicPlayerVisualMusicPlayerPresenter.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class VisualMusicPlayerPresenter: VisualMusicPlayerModuleInput, VisualMusicPlayerViewOutput, VisualMusicPlayerInteractorOutput {

    weak var view: VisualMusicPlayerViewInput!
    var interactor: VisualMusicPlayerInteractorInput!
    var router: VisualMusicPlayerRouterInput!

    func viewIsReady() {

    }
}
