//
//  LikeFilterLikeFilterPresenter.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LikeFilterPresenter: LikeFilterModuleInput, LikeFilterViewOutput, LikeFilterInteractorOutput {

    weak var view: LikeFilterViewInput!
    var interactor: LikeFilterInteractorInput!
    var router: LikeFilterRouterInput!

    func viewIsReady() {

    }
}
