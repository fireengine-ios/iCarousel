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
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    // MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: FileInfoViewOutput

extension FileInfoPresenter: FileInfoViewOutput {
    func viewIsReady() {
        interactor.viewIsReady()
        ItemOperationManager.default.startUpdateView(view: self)
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
        guard let item = interactor.item else {
            return
        }
        
        router.openPrivateShareAccessList(projectId: item.accountUuid,
                                          uuid: item.uuid,
                                          contact: contact,
                                          fileType: item.fileType)
    }
}

// MARK: FileInfoInteractorOutput

extension FileInfoPresenter: FileInfoInteractorOutput {
    func showProgress() {
        view.showProgress()
    }

    func hideProgress() {
        view.hideProgress()
    }

    func setObject(object: BaseDataSourceItem) {
        view.setObject(object)
    }
    
    func displayEntityInfo(_ sharingInfo: SharedFileInfo) {
        view.showEntityInfo(sharingInfo)
    }
}

// MARK: FileInfoModuleInput

extension FileInfoPresenter: FileInfoModuleInput {

}

//MARK: - FileInfoRouterOutput

extension FileInfoPresenter: FileInfoRouterOutput {
    func updateEntityInfo() {
        interactor.getEntityInfo()
    }
}

//MARK: - ItemOperationManagerViewProtocol

extension FileInfoPresenter: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        object === self
    }
    
    func didShare(items: [BaseDataSourceItem]) {
        if let uuid = interactor.item?.uuid, items.first(where: { $0.uuid == uuid }) != nil {
            updateEntityInfo()
        }
    }
    
    func didEndShareItem(uuid: String) {
        if uuid == interactor.item?.uuid {
            updateEntityInfo()
        }
    }
    
    func didChangeRole(_ role: PrivateShareUserRole, contact: SharedContact, uuid: String) {
        if uuid == interactor.item?.uuid, interactor.sharingInfo?.members?.contains(contact) == true {
            updateEntityInfo()
        }
    }
    
    func didRemove(contact: SharedContact, fromItem uuid: String) {
        if uuid == interactor.item?.uuid, interactor.sharingInfo?.members?.contains(contact) == true {
            updateEntityInfo()
        }
    }
}
