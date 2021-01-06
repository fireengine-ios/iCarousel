//
//  PrivateShareAnalytics.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

private enum ContactsPermission {
    case allow
    case doNotAllow
    
    var trackValue: String {
        switch self {
        case .allow:
            return "Allow"
        case .doNotAllow:
            return "Do not Allow"
        }
    }
    
    init(status: CNAuthorizationStatus) {
        switch status {
        case .authorized:
            self = .allow
        default:
            self = .doNotAllow
        }
    }
}

final class PrivateShareAnalytics {
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    enum SharedScreen {
        case sharedWithMe
        case sharedByMe
        case whoHasAccess
        case sharedAccess
        case shareInfo
    }
    
    enum SharedWithMeAction {
        case delete
        case rename
        case download
        case createFolder
        case preview
    }
    
    enum ContactsPermissionType {
        case allowed
        case denied
        case notAskAgain
        
        init(isAllowed: Bool, askedPermissions: Bool) {
            if !askedPermissions {
                self = .notAskAgain
            } else if isAllowed {
                self = .allowed
            } else {
                self = .denied
            }
        }
    }
    
    //MARK: - Public Actions
    
    func openAllSharedFiles() {
        trackSharedFolderEvent(eventAction: .click, eventLabel: .privateShare(.seeAll))
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.SeeAllSharedEvent())
    }
    
    func trackScreen(_ screen: SharedScreen) {
        let gaScreen: AnalyticsAppScreens
        let netmeraScreen: NetmeraScreenEventTemplate
        
        switch screen {
        case .sharedWithMe:
            gaScreen = .sharedWithMe
            netmeraScreen = NetmeraEvents.Screens.SharedWithMeScreen()
        case .sharedByMe:
            gaScreen = .sharedByMe
            netmeraScreen = NetmeraEvents.Screens.SharedByMeScreen()
        case .whoHasAccess:
            gaScreen = .whoHasAccess
            netmeraScreen = NetmeraEvents.Screens.WhoHasAccessScreen()
        case .sharedAccess:
            gaScreen = .sharedAccess
            netmeraScreen = NetmeraEvents.Screens.SharedAccessScreenScreen()
        case .shareInfo:
            gaScreen = .shareInfo
            netmeraScreen = NetmeraEvents.Screens.PrivateShareInfoScreen()
        }
        
        analyticsService.logScreen(screen: gaScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: gaScreen)
        AnalyticsService.sendNetmeraEvent(event: netmeraScreen)
    }
    
    func openPrivateShare() {
        trackSharedFolderEvent(eventAction: .click, eventLabel: .privateShare(.privateShare))
    }
    
    func successShare(items: [BaseDataSourceItem], duration: PrivateShareDuration, message: String?) {
        let gaLabels = items.compactMap { convertFileTypeToGAType($0.fileType) }
        
        let dict = Dictionary(grouping: gaLabels, by: { $0 } )
        let label = Array(dict.keys).map { $0.text }.joined(separator: ",")
        
        var parameters = ["sharedCount": items.count]
        dict.forEach { type, array in
            switch type {
            case .photo:
                parameters["sharedCountPhoto"] = array.count
            case .video:
                parameters["sharedCountVideo"] = array.count
            case .document:
                parameters["sharedCountDocument"] = array.count
            case .music:
                parameters["sharedCountMusic"] = array.count
            case .folder:
                parameters["sharedCountFolder"] = array.count
            default:
                break
            }
        }

        trackSharedFolderEvent(eventAction: .share, eventLabel: .custom(label), shareParameters: parameters)
        trackSharedFolderEvent(eventAction: .duration, eventLabel: .privateShare(.duration(duration)))
        
        let messageLabel: GAEventLabel
        if let message = message, !message.isEmpty {
            messageLabel = .custom("filled")
        } else {
            messageLabel = .custom("not filled")
        }
        
        trackSharedFolderEvent(eventAction: .message, eventLabel: messageLabel)
        
        let netmeraShareEvent = NetmeraEvents.Actions.Share(method: .private, channelType: "", duration: duration)
        AnalyticsService.sendNetmeraEvent(event: netmeraShareEvent)
    }
    
    func endShare(item: BaseDataSourceItem) {
        let gaFileType = convertFileTypeToGAType(item.fileType) ?? .photo
        trackSharedFolderEvent(eventAction: .endShare, eventLabel: .fileTypeOperation(gaFileType))
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.EndShareEvent())
    }
    
    func leaveShare(item: BaseDataSourceItem) {
        let gaFileType = convertFileTypeToGAType(item.fileType) ?? .photo
        trackSharedFolderEvent(eventAction: .leaveShare, eventLabel: .fileTypeOperation(gaFileType))
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.LeaveShareEvent())
    }
    
    func addApiSuggestion() {
        trackSharedFolderEvent(eventAction: .click, eventLabel: .privateShare(.apiSuggestion))
    }
    
    func addPhonebookSuggestion() {
        trackSharedFolderEvent(eventAction: .click, eventLabel: .privateShare(.phonebookSuggestion))
    }
    
    func sharedWithMe(action: SharedWithMeAction, on item: BaseDataSourceItem? = nil) {
        let gaFileType = convertFileTypeToGAType(item?.fileType)
        let gaAction: GAEventAction
        
        switch action {
        case .delete:
            gaAction = .delete
        case .rename:
            gaAction = .rename
        case .download:
            gaAction = .download
        case .createFolder:
            gaAction = .createNewFolder
        case .preview:
            gaAction = .preview
        }
        
        let label: GAEventLabel
        if let type = gaFileType {
           label = .fileTypeOperation(type)
        } else {
            label = .empty
        }
        
        trackSharedFolderEvent(eventAction: gaAction, eventLabel: label)
    }
    
    func sharedWithMeUploadedItems(count: Int) {
        let shareParameters = ["sharedUploadCount": count]
        analyticsService.trackSharedFolderEvent(eventAction: .upload,
                                                eventLabel: .empty,
                                                shareParameters: shareParameters)
    }
    
    func removeFromShare() {
        trackSharedFolderEvent(eventAction: .removeUser, eventLabel: .empty)
    }
    
    func changeRoleFromViewerToEditor() {
        trackSharedFolderEvent(eventAction: .changeRoleFromViewerToEditor, eventLabel: .empty)
    }
    
    func changeRoleFromEditorToViewer() {
        trackSharedFolderEvent(eventAction: .changeRoleFromEditorToViewer, eventLabel: .empty)
    }
    
    private func trackSharedFolderEvent(eventAction: GAEventAction, eventLabel: GAEventLabel, shareParameters: [String: Any] = [:]) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        let permissionDict = ["ContactPermission": ContactsPermission(status: status).trackValue]
        analyticsService.trackSharedFolderEvent(eventAction: eventAction,
                                                eventLabel: eventLabel,
                                                shareParameters: permissionDict + shareParameters)
    }

    //MARK: - Helpers
    
    private func convertFileTypeToGAType(_ fileType: FileType?) -> GAEventLabel.FileType? {
        switch fileType {
        case .image:
            return .photo
        case .video:
            return .video
//        case .faceImage(let type):
//            switch type {
//            case .people:
//                return .people
//            case .places:
//                return .places
//            case .things:
//                return .things
//            }
//        case .photoAlbum:
//            return .albums
        case .audio:
            return .music
        case .folder:
            return .folder
        case .application(let type):
            if type.isContained(in: [.doc, .txt, .html, .xls, .pdf, .ppt, .pptx, .usdz]) {
                return .document
            }
            return nil
        default:
            return nil
        }
    }
}
