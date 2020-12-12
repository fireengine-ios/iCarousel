//
//  PrivateShareAnalytics.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

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
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .click,
                                            eventLabel: .privateShare(.seeAll))
        
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
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .click,
                                            eventLabel: .privateShare(.privateShare))
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

        analyticsService.trackStartShare(label: label, shareParameters: parameters)
        
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .duration,
                                            eventLabel: .privateShare(.duration(duration)))
        
        let messageLabel: GAEventLabel
        if let message = message, !message.isEmpty {
            messageLabel = .custom("filled")
        } else {
            messageLabel = .custom("not filled")
        }
        
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .message,
                                            eventLabel: messageLabel)
        
        let netmeraShareEvent = NetmeraEvents.Actions.Share(method: .private, channelType: "", duration: duration)
        AnalyticsService.sendNetmeraEvent(event: netmeraShareEvent)
    }
    
    func endShare(item: BaseDataSourceItem) {
        let gaFileType = convertFileTypeToGAType(item.fileType) ?? .photo
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .endShare,
                                            eventLabel: .fileTypeOperation(gaFileType))
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.EndShareEvent())
    }
    
    func leaveShare(item: BaseDataSourceItem) {
        let gaFileType = convertFileTypeToGAType(item.fileType) ?? .photo
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .leaveShare,
                                            eventLabel: .fileTypeOperation(gaFileType))
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.LeaveShareEvent())
    }
    
    func addApiSuggestion() {
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .click,
                                            eventLabel: .privateShare(.apiSuggestion))
    }
    
    func addPhonebookSuggestion() {
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .click,
                                            eventLabel: .privateShare(.phonebookSuggestion))
    }
    
    func sendContactPermission(result: (isAllowed: Bool, askedPermissions: Bool)) {
        let type = ContactsPermissionType(isAllowed: result.isAllowed, askedPermissions: result.askedPermissions)
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .contactPermission,
                                            eventLabel: .privateShare(.contactPermission(type)))
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
        
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: gaAction,
                                            eventLabel: label)
    }
    
    func sharedWithMeUploadedItems(count: Int) {
        let shareParameters = ["sharedUploadCount": count]
        analyticsService.trackUploadShareWithMeItems(shareParameters: shareParameters)
    }
    
    func removeFromShare() {
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .removeUser)
    }
    
    func changeRoleFromViewerToEditor() {
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .changeRoleFromViewerToEditor)
    }
    
    func changeRoleFromEditorToViewer() {
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .changeRoleFromEditorToViewer)
    }

    //MARK: - Helpers
    
    private func convertFileTypeToGAType(_ fileType: FileType?) -> GAEventLabel.FileType? {
        switch fileType {
        case .image:
            return .photo
        case .video:
            return .video
        case .faceImage(let type):
            switch type {
            case .people:
                return .people
            case .places:
                return .places
            case .things:
                return .things
            }
        case .photoAlbum:
            return .albums
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
