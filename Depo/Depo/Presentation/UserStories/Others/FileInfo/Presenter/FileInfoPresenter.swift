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
    
    func shareItem() {
        if let item = interactor.item as? WrapData {
            router.openPrivateShare(for: item)
        }
    }
    
    func showWhoHasAccess(shareInfo: SharedFileInfo) {
        router.openPrivateShareContacts(with: shareInfo)
    }
    
    func openShareAccessList(contact: SharedContact) {
        guard let item = interactor.item, let projectId = item.projectId else {
            return
        }
        
        router.openPrivateShareAccessList(projectId: projectId,
                                          uuid: item.uuid,
                                          contact: contact,
                                          fileType: item.fileType)
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
            view.setObject(object)
        }
    }
    
    func updated() {
        asyncOperationSuccess()
        view.goBack()
    }
    
    func albumForUuidSuccessed(album: AlbumServiceResponse) {
        let albumItem = AlbumItem(remote: album)
        view.showViews()
        view.setObject(albumItem)
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
    
    func displayShareInfo(_ sharingInfo: SharedFileInfo) {
        view.showSharingInfo(sharingInfo)
    }
}

// MARK: FileInfoModuleInput

extension FileInfoPresenter: FileInfoModuleInput {

}

//MARK: - FileInfoRouterOutput

extension FileInfoPresenter: FileInfoRouterOutput {
    
    func updateSharingInfo() {
        interactor.getSharingInfo()
    }
    
    func deleteSharingInfo() {
        view.deleteSharingInfo()
    }
}

