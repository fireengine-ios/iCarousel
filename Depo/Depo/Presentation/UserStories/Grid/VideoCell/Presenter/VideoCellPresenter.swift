//
//  VideoCellVideoCellPresenter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class VideoCellPresenter: VideoCellModuleInput, VideoCellViewOutput, VideoCellInteractorOutput {

    weak var view: VideoCellViewInput!
    var interactor: VideoCellInteractorInput!
    var router: VideoCellRouterInput!

    func viewIsReady() {

    }
}
