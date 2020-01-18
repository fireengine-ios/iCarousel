//
//  FileInfoFileInfoPresenter.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class FileInfoPresenter: BasePresenter {

    weak var view: FileInfoViewInput!
    var interactor: FileInfoInteractorInput!
    var router: FileInfoRouterInput!
    
    var fileInfoModuleOutput: FileInfoModuleOutput?
    
    // MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: FileInfoViewOutput

extension FileInfoPresenter: FileInfoViewOutput {
    
    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func validateName(newName: String) {
        interactor.onValidateName(newName: newName)
    }
    
    func onRename(newName: String) {
        startAsyncOperation()
        interactor.onRename(newName: newName)
    }
    
}

// MARK: FileInfoInteractorOutput

extension FileInfoPresenter: FileInfoInteractorOutput {
    
    func setObject(object: BaseDataSourceItem) {
        if object.fileType == .photoAlbum {
            view.hideViews()
            view.startActivityIndicator()
            interactor.getAlbum(for: object)
        } else {
            view.setObject(object: object)
        }
    }
    
    func updated() {
        fileInfoModuleOutput?.didRenameItem(interactor.item)
        asyncOperationSuccess()
        view.goBack()
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

    func cancelSave(use name: String) {
        asyncOperationSuccess()
        view.show(name: name)
    }
    
    func failedUpdate(error: Error) {
        asyncOperationSuccess()
        view.showErrorAlert(message: error.description)
    }
    
    func didValidateNameSuccess() {
        view.showValidateNameSuccess()
    }
    
}

// MARK: FileInfoModuleInput

extension FileInfoPresenter: FileInfoModuleInput {

}


