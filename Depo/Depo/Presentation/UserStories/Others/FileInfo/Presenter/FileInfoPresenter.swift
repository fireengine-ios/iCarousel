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
        if object.fileType == .photoAlbum {
            view.hideViews()
            view.startActivityIndicator()
            interactor.getAlbum(for: object)
        } else {
            view.setObject(object: object)
        }
    }
    
    func albumForUuidSuccessed(album: AlbumServiceResponse) {
        let albumItem = AlbumItem(remote: album)
        view.showViews()
        view.setObject(object: albumItem)
        view.stopActivityIndicator()
    }
    
    func albumForUuidFailed(error: Error) {
        view.stopActivityIndicator()
        view.showErrorAlert(message: error.description)
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
