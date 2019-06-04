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
    private lazy var albumService = PhotosAlbumService()

}

// MARK: FileInfoInteractorInput

extension FileInfoInteractor: FileInfoInteractorInput {
    
    func setObject(object: BaseDataSourceItem) {
        item = object
    }
    
    func viewIsReady() {
        if let item = item {
            output.setObject(object: item)
            AnalyticsService().logScreen(screen: .info(item.fileType))
        }
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
        
        if let file = item as? Item {
            let renameFile = RenameFile(uuid: file.uuid, newName: newName)
            FileService().rename(rename: renameFile, success: { [weak self] in
                DispatchQueue.main.async {
                    self?.output.updated()
                    if let file = self?.item {
                        file.name = newName
                    }
                }
                }, fail: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.output.failedUpdate(error: error)
                    }
            })
        }
        
        if let album = item as? AlbumItem {
            let renameAlbum = RenameAlbum(albumUUID: album.uuid, newName: newName)
            PhotosAlbumService().renameAlbum(parameters: renameAlbum, success: { [weak self] in
                DispatchQueue.main.async {
                    self?.output.updated()
                    if let file = self?.item {
                        file.name = newName
                    }
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
    
}
