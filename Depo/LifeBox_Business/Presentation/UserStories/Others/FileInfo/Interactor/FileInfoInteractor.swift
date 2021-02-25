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

    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private lazy var analytics = PrivateShareAnalytics()
}

// MARK: FileInfoInteractorInput

extension FileInfoInteractor: FileInfoInteractorInput {
    
    func viewIsReady() {
        guard let item = item else {
            return
        }
        output.setObject(object: item)
        getEntityInfo()
        AnalyticsService().logScreen(screen: .info(item.fileType))
    }
    
    func getEntityInfo() {
        guard item?.isLocalItem == false,
              let accountUuid = item?.accountUuid,
              let uuid = item?.uuid else {
            return
        }
        
        if let item = item as? Item,
           item.status != .active {
            return
        }
        
        var sharingInfo: SharedFileInfo?
            
        shareApiService.getRemoteEntityInfo(projectId: accountUuid,
                                            uuid: uuid) { [weak self] result in
            switch result {
            case .success(let info):
                sharingInfo = info
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }

            if let sharingInfo = sharingInfo {
                self?.output.displayEntityInfo(sharingInfo)
            }
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
