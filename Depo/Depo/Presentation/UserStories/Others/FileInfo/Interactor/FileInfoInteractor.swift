//
//  FileInfoFileInfoInteractor.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FileInfoInteractor: FileInfoInteractorInput {

    weak var output: FileInfoInteractorOutput!
    
    var item: BaseDataSourceItem?

    func setObject(object: BaseDataSourceItem) {
        item = object
    }
    
    func viewIsReady() {
        if let item = item {
            output.setObject(object: item)
        }
    }
    
    func onRename(newName: String) {
        if let file = item as? Item {
            let renameFile = RenameFile(uuid: file.uuid, newName: newName)
            FileService().rename(rename: renameFile, success: {
                DispatchQueue.main.async { [weak self] in
                    self?.output.updated()
                    if let file = self?.item {
                        file.name = newName
                    }
                }
            }, fail: { error in
                DispatchQueue.main.async { [weak self] in
                    self?.output.updated()
                }
            })

        }
        
        if let album = item as? AlbumItem {
            let renameAlbum = RenameAlbum(albumUUID: album.uuid, newName: newName)
            PhotosAlbumService().renameAlbum(parameters: renameAlbum, success: {
                DispatchQueue.main.async { [weak self] in
                    self?.output.updated()
                    if let file = self?.item {
                        file.name = newName
                    }
                }
            }, fail: { error in
                DispatchQueue.main.async { [weak self] in
                    self?.output.updated()
                }
            })
        }
    }
    
}
