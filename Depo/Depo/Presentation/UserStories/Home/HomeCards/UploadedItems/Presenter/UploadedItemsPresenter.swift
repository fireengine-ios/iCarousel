//
//  UploadedItemsUploadedItemsPresenter.swift
//  Depo
//
//  Created by Oleg on 27/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadedItemsPresenter: UploadedItemsModuleInput, UploadedItemsViewOutput, UploadedItemsInteractorOutput {

    weak var view: UploadedItemsViewInput!
    var interactor: UploadedItemsInteractorInput!
    var router: UploadedItemsRouterInput!

    func viewIsReady() {

    }
}
