//
//  FileInfoFileInfoPresenter.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FileInfoPresenter: BasePresenter, FileInfoModuleInput, FileInfoViewOutput, FileInfoInteractorOutput {

    weak var view: FileInfoViewInput!
    var interactor: FileInfoInteractorInput!
    var router: FileInfoRouterInput!

    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func setObject(object: BaseDataSourceItem) {
        view.setObject(object: object)
    }
    
    func onRename(newName: String) {
        startAsyncOperation()
        interactor.onRename(newName: newName)
    }
    
    func updated() {
        asyncOperationSucces()
        view.goBack()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
