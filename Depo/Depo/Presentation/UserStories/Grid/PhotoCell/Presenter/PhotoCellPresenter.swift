//
//  PhotoCellPhotoCellPresenter.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoCellPresenter : BasePresenter, PhotoCellModuleInput, PhotoCellViewOutput, PhotoCellInteractorOutput {

    var view: PhotoCellViewInput!
    var interactor: PhotoCellInteractorInput!
    var router: PhotoCellRouterInput!

    func viewIsReady() {
//        startAsyncOperation()
    }
    
    func showImage(image: UIImage) {
//        asyncOperationSucces()

        view.showImage(image: image)
    }
    
    //MARK : BasePresenter
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
