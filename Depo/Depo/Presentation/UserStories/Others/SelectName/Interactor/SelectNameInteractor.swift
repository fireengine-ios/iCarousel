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
    private lazy var privateShareService = PrivateShareApiServiceImpl()
    
    var rootFolderID: String?
    var isFavorite: Bool?
    var isPrivateShare: Bool = false
    var projectId: String?
    
    
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
        if isPrivateShare {
            createFolderOnSharedWithMe(with: name)
        } else {
            createFolderOnAllFiles(with: name)
        }
    }
    
    private func createFolderOnSharedWithMe(with name: String) {
        guard let projectId = projectId, let parentFolderUuid = rootFolderID else {
            return
        }

        let requestItem = CreateFolderResquestItem(uuid: UUID().uuidString, name: name)
        privateShareService.createFolder(projectId: projectId, parentFolderUuid: parentFolderUuid, requestItem: requestItem) { [weak self] response in
            switch response {
                case .success(let createdFolder):
                    DispatchQueue.main.async {
                        if let self = self {
                            let isSubfolder = self.rootFolderID != nil
                            let wrapDataItem = WrapData(privateShareFileInfo: createdFolder)
                            self.output.operationSuccess(operation: self.moduleType, item: wrapDataItem, isSubFolder: isSubfolder)
                            ItemOperationManager.default.newFolderCreated()
                        }
                    }
                    
                case .failed(let error):
                    DispatchQueue.main.async {
                        self?.output.operationFailedWithError(errorMessage: error.description)
                    }
            }
        }
    }
    
    private func createFolderOnAllFiles(with name: String) {
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
