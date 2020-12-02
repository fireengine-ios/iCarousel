//
//  FileInfoFileInfoInteractor.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class FileInfoInteractor {
    
    weak var output: FileInfoInteractorOutput!
    
    var item: BaseDataSourceItem?
    private(set) var sharingInfo: SharedFileInfo?
    private let albumService = PhotosAlbumService()

    private lazy var localContactsService = ContactsSuggestionServiceImpl()
    private lazy var shareApiService = PrivateShareApiServiceImpl()
}

// MARK: FileInfoInteractorInput

extension FileInfoInteractor: FileInfoInteractorInput {
    
    func viewIsReady() {
        guard let item = item else {
            return
        }
        output.setObject(object: item)
        getSharingInfo()
        AnalyticsService().logScreen(screen: .info(item.fileType))
    }
    
    func onRename(newName: String) {
        guard !newName.isEmpty else {
            if let name = item?.name {
                output.cancelSave(use: name)
            } else {
                output.updated()
            }
            
            return
        }
        
        if let item = item as? Item, let projectId = item.projectId {
            shareApiService.renameItem(projectId: projectId, uuid: item.uuid, name: newName) { [weak self] result in
                switch result {
                case .success():
                    item.name = newName
                    self?.output.updated()
                    ItemOperationManager.default.didRenameItem(item)
                    
                case .failed(let error):
                    self?.output.failedUpdate(error: error)
                }
            }
        }
        
        if let album = item as? AlbumItem {
            let renameAlbum = RenameAlbum(albumUUID: album.uuid, newName: newName)
            albumService.renameAlbum(parameters: renameAlbum, success: { [weak self] in
                DispatchQueue.main.async {
                    self?.item?.name = newName
                    self?.output.updated()
                }
                }, fail: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.output.updated()
                    }
            })
        }
    }
    
    func getAlbum(for item: BaseDataSourceItem) {
        albumService.getAlbum(for: item.uuid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let album):
                    self?.output.albumForUuidSuccessed(album: album)
                case .failed(let error):
                    self?.output.albumForUuidFailed(error: error)
                }
            }
        }
    }
    
    func onValidateName(newName: String) {
        if newName.isEmpty {
            if let name = item?.name {
                output.cancelSave(use: name)
            }
        } else {
            output.didValidateNameSuccess()
        }
    }
    
    func getSharingInfo() {
        guard item?.isLocalItem == false, let projectId = item?.projectId , let uuid = item?.uuid else {
            return
        }
        
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        var hasAccess = false
        var sharingInfo: SharedFileInfo?
        
        localContactsService.fetchAllContacts { isAuthorized in
            hasAccess = isAuthorized
            group.leave()
        }
            
        shareApiService.getSharingInfo(projectId: projectId, uuid: uuid) { result in
            switch result {
            case .success(let info):
                sharingInfo = info
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            if let sharingInfo = sharingInfo {
                self?.setupSharingInfoView(sharingInfo: sharingInfo, hasAccess: hasAccess)
            }
        }
    }
    
    private func setupSharingInfoView(sharingInfo: SharedFileInfo, hasAccess: Bool) {
        let hasMembers = sharingInfo.members?.isEmpty == false
        
        if hasMembers {
            var info = sharingInfo
            info.members?.enumerated().forEach { index, member in
                let localContactNames = localContactsService.getContactName(for: member.subject?.username ?? "", email: member.subject?.email ?? "")
                info.members?[index].subject?.name = displayName(from: localContactNames)
            }
            self.sharingInfo = info
            output.displayShareInfo(info)
        } else {
            output.displayShareInfo(sharingInfo)
        }
    }
    
    private func displayName(from localNames: LocalContactNames) -> String {
        if !localNames.givenName.isEmpty, !localNames.familyName.isEmpty {
            return "\(localNames.givenName) \(localNames.familyName)"
        } else if !localNames.givenName.isEmpty {
            return localNames.givenName
        } else {
            return localNames.familyName
        }
    }
    
}
