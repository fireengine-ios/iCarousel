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

    private lazy var localContactsService = ContactsSuggestionServiceImpl()
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
        getSharingInfo()
        AnalyticsService().logScreen(screen: .info(item.fileType))
    }
    
    func getSharingInfo() {
        guard item?.isLocalItem == false, let accountUuid = item?.accountUuid , let uuid = item?.uuid else {
            return
        }
        
        if let item = item as? Item, item.status != .active {
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
            
        shareApiService.getSharingInfo(projectId: accountUuid, uuid: uuid) { result in
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
