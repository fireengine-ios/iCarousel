//
//  SelectNameSelectNameInteractor.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum SelectNameScreenType: Int {
    case selectPlayListName = 2
    case selectFolderName = 3
}

class SelectNameInteractor: SelectNameInteractorInput {

    weak var output: SelectNameInteractorOutput!
    
    var moduleType: SelectNameScreenType = .selectFolderName
    
    private lazy var privateShareService = PrivateShareApiServiceImpl()
    private lazy var analytics = PrivateShareAnalytics()
    
    var rootFolderID: String?
    var isFavorite: Bool?
    var isPrivateShare: Bool = false
    var projectId: String?
    
    
    func getTitle() -> String {
        switch moduleType {
        case .selectPlayListName:
            return TextConstants.selectNameTitlePlayList
        case .selectFolderName:
            return TextConstants.selectNameTitleFolder
        }
    }
    
    func getNextButtonText() -> String {
        switch moduleType {
        case .selectPlayListName:
            return TextConstants.selectNameNextButtonPlayList
        case .selectFolderName:
            return TextConstants.selectNameNextButtonFolder
        }
    }
    
    func getPlaceholderText() -> String {
        switch moduleType {
        case .selectPlayListName:
            return TextConstants.selectNamePlaceholderPlayList
        case .selectFolderName:
            return TextConstants.selectNamePlaceholderFolder
        }
    }
    
    func getTextForEmptyTextFieldAllert() -> String {
        switch moduleType {
        case .selectPlayListName:
            return TextConstants.selectNameEmptyNamePlayList
        case .selectFolderName:
            return TextConstants.selectNameEmptyNameFolder
        }
    }
    
    func onNextButton(name: String) {
        output.startProgress()
        switch moduleType {
        case .selectPlayListName:
            onCreatePlayListWithName(name: name)
        case .selectFolderName:
            onCreateFolderWithName(name: name)
        }
    }
    
    
    // MARK: requests
    
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
                            self.analytics.sharedWithMe(action: .createFolder, on: nil)
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
