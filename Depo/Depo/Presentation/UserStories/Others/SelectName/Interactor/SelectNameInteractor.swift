//
//  SelectNameSelectNameInteractor.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum SelectNameScreenType: Int {
    case selectAlbumName = 1
    case selectPlayListName = 2
    case selectFolderName = 3
}

class SelectNameInteractor: SelectNameInteractorInput {

    weak var output: SelectNameInteractorOutput!
    
    var moduleType: SelectNameScreenType = .selectAlbumName
    
    private let albumService = PhotosAlbumService()
    
    var rootFolderID: String?
    var isFavorite: Bool?
    
    func getTitle() -> String {
        switch moduleType {
        case .selectAlbumName:
            return TextConstants.selectNameTitleAlbum
        case .selectPlayListName:
            return TextConstants.selectNameTitlePlayList
        case .selectFolderName:
            return TextConstants.selectNameTitleFolder
        }
    }
    
    func getNextButtonText() -> String {
        switch moduleType {
        case .selectAlbumName:
            return TextConstants.selectNameNextButtonAlbum
        case .selectPlayListName:
            return TextConstants.selectNameNextButtonPlayList
        case .selectFolderName:
            return TextConstants.selectNameNextButtonFolder
        }
    }
    
    func getPlaceholderText() -> String {
        switch moduleType {
        case .selectAlbumName:
            return TextConstants.selectNamePlaceholderAlbum
        case .selectPlayListName:
            return TextConstants.selectNamePlaceholderPlayList
        case .selectFolderName:
            return TextConstants.selectNamePlaceholderFolder
        }
    }
    
    func getTextForEmptyTextFieldAllert() -> String {
        switch moduleType {
        case .selectAlbumName:
            return TextConstants.selectNameEmptyNameAlbum
        case .selectPlayListName:
            return TextConstants.selectNameEmptyNamePlayList
        case .selectFolderName:
            return TextConstants.selectNameEmptyNameFolder
        }
    }
    
    func onNextButton(name: String) {
        output.startProgress()
        switch moduleType {
        case .selectAlbumName:
            onCreateAlbumWithName(name: name)
        case .selectPlayListName:
            onCreatePlayListWithName(name: name)
        case .selectFolderName:
            onCreateFolderWithName(name: name)
        }
    }
    
    
    // MARK: requests
    
    private func onCreateAlbumWithName(name: String) {
        let createAlbumParams = CreatesAlbum(albumName: name)
        albumService.createAlbum(createAlbum: createAlbumParams, success: { [weak self] albumItem in
            DispatchQueue.main.async {
                if let self_ = self {
                    self_.output.createAlbumOperationSuccess(item: albumItem)
                    ItemOperationManager.default.newAlbumCreated()
                }
            }
        }) { error in
            DispatchQueue.main.async { [weak self] in
                self?.output.operationFailedWithError(errorMessage: error.description)
            }
        }
    }
    
    private func onCreatePlayListWithName(name: String) {
        
    }
    
    private func onCreateFolderWithName(name: String) {
        let createfolderParam = CreatesFolder(folderName: name,
                                              rootFolderName: rootFolderID ?? "",
                                              isFavourite: isFavorite ?? false)
        
        WrapItemFileService().createsFolder(createFolder: createfolderParam,
            success: { [weak self] (item) in
                DispatchQueue.main.async {
                    if let self_ = self {
                        let isSubfolder = self_.rootFolderID != nil
                        self_.output.operationSuccess(operation: self_.moduleType, item: item, isSubFolder: isSubfolder)
                        ItemOperationManager.default.newFolderCreated()
                    }
                }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.output.operationFailedWithError(errorMessage: error.description)
                }
        })
    }

}
