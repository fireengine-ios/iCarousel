//
//  ElementTypes.swift
//  Depo
//
//  Created by Andrei Novikau on 5/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum ElementTypes {
    case share
    case info//one for alert one for tab
    case edit
    case delete
    case emptyTrashBin
    case deleteDeviceOriginal
    case move
    case sync
    case syncInProgress
    case download
    case downloadDocument
    case undetermend
    case rename
    case removeAlbum
    case moveToTrash
    case restore
    
    //used only in alert sheet:
    //photos:
    case createStory
    case createAlbum
    case copy
    case addToFavorites
    case removeFromFavorites
    case addToAlbum
    case backUp
    case addToCmeraRoll
    case removeFromAlbum
    case removeFromFaceImageAlbum
    case print
    case changeCoverPhoto
    case changePeopleThumbnail
    case hide
    case unhide
    case smash
    //upload?
    case photos
    case iCloudDrive
    case lifeBox
    case more
    //all files/select
    case select
    case selectAll
    case selectMode
    case deleteAll
    case onlyUnreadOn
    case onlyUnreadOff
    case onlyShowAlertsOn
    case onlyShowAlertsOff
    case deSelectAll
    //doc viewing
    case documentDetails
    //music
    case addToPlaylist
    case musicDetails
    case shareAlbum
    case makeAlbumCover
    case makePersonThumbnail
    case albumDetails
    //instaPick
    case instaPick
    //private share
    case endSharing
    case leaveSharing
    case moveToTrashShared
    //createCollage
    case collageSave
    case collageChange
    case collageDelete
    case collageCancel
    
    case shareOriginal
    case shareLink
    case sharePrivate
    
    case galleryAll
    case galleryPhotos
    case galleryVideos
    case gallerySync
    case galleryUnsync
    
    //onlyOffice
    case officeFilterAll
    case officeFilterPdf
    case officeFilterWord
    case officeFilterCell
    case officeFilterSlide
    
    static var trashState: [ElementTypes] = [.restore, .delete]
    static var hiddenState: [ElementTypes] = [.unhide, .moveToTrash]
    static var activeState: [ElementTypes] = [.hide, .moveToTrash]
    static var activeStatePeople: [ElementTypes] = [.print, .moveToTrash]

    static func detailsElementsConfig(for item: Item, status: ItemStatus, viewType: DetailViewType) -> [ElementTypes] {
        var result = [ElementTypes]()
        
        if item.isPublicSharedItem == true {
            return []
        }
        
        if !item.isOwner {
            //shared with me items
            if let grantedPermissions = item.privateSharePermission?.granted {
                if grantedPermissions.contains(.read) {
                    if item.fileType.isContained(in: [.image, .video]) {
                        result.append(.download)
                    } else {
                        result.append(.downloadDocument)
                    }
                }
                
                if grantedPermissions.contains(.delete) {
                    if !item.isReadOnlyFolder {
                        result.append(.moveToTrashShared)
                    }
                }
            }
            return result
        }
        
        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
        case .trashed:
            result = ElementTypes.trashState
        default:
            if item.isLocalItem {
                let inProgress = UploadService.default.isInQueue(item: item.uuid)
                result = [inProgress ? .syncInProgress : .sync, .info]
            } else {
                switch item.fileType {
                case .image, .video:
                    result = [.share, .download]
                    
                    if item.fileType == .image {
                        result.append(.edit)
                    }

                default:
                    result = [.share, .download, .moveToTrash]
                }
                
                if item.fileType.isContained(in: [.video, .image]) {
                    switch viewType {
                    case .details:
                        result.append(.moveToTrash)
                    case .insideAlbum:
                        result.append(.removeFromAlbum)
                    case .insideFIRAlbum:
                        result.append(.removeFromFaceImageAlbum)
                    }
                }
            }
        }
        
        return result
    }
    
    static func albumElementsConfig(for status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
            if viewType != .bottomBar {
                result.insert(.select, at: 0)
            }
            
        case .trashed:
            result = ElementTypes.trashState
            if viewType != .bottomBar {
                result.insert(.select, at: 0)
            }
            
        default:
            switch viewType {
            case .bottomBar:
                result = [.share, .download, .addToAlbum]  + ElementTypes.activeState
                
            case .actionSheet:
                result = [.select, .changeCoverPhoto, .shareAlbum, .download, .removeAlbum, .albumDetails]  + ElementTypes.activeState
                
            case .actionSheetWithoutChangeCover:
                result = [.select, .shareAlbum, .download, .removeAlbum, .albumDetails]  + ElementTypes.activeState
                
            case .selectionMode:
                result = [.createStory, .addToFavorites, .removeFromFavorites]
                result.append(.removeFromAlbum)
            }
        }
        
        return result
    }
    
    static func faceImagePhotosElementsConfig(for item: Item, status: ItemStatus, viewType: UniversalViewType, faceImageType: FaceImageType? = nil) -> [ElementTypes] {
        var result: [ElementTypes]

        switch viewType {
        case .bottomBar:
            switch status {
            case .hidden:
                result = ElementTypes.hiddenState
                
            case .trashed:
                result = ElementTypes.trashState
                
            default:
                result = [.share, .download, .addToAlbum]
                
                if SingletonStorage.shared.accountInfo?.isUserFromTurkey == true {
                    result =  [.share, .download, .addToAlbum] + ElementTypes.activeStatePeople
                }
            }
            
        case .actionSheet:
            result = [.select]

            if item.fileType.isFaceImageType {
                switch status {
                case .hidden:
                    result.append(contentsOf: ElementTypes.hiddenState)
                    
                case .trashed:
                    result.append(contentsOf: ElementTypes.trashState)
                    
                default:
                    if faceImageType == .people {
                        result.append(.changePeopleThumbnail)
                    }
                    result.append(contentsOf: [.share] + ElementTypes.activeState)
                }
            }
            
        case .selectionMode:
            switch status {
            case .hidden:
                result = ElementTypes.hiddenState
                
            case .trashed:
                result = ElementTypes.trashState
                
            default:
                result = [.createStory]
                result.append(.removeFromFaceImageAlbum)
                result.append(.hide)
            }
        case .actionSheetWithoutChangeCover:
            result = [.select]

            if item.fileType.isFaceImageType {
                switch status {
                case .hidden:
                    result.append(contentsOf: ElementTypes.hiddenState)
                    
                case .trashed:
                    result.append(contentsOf: ElementTypes.trashState)
                    
                default:
                    if faceImageType == .people {
                        result.append(.changePeopleThumbnail)
                    }
                    result.append(contentsOf: [.share] + ElementTypes.activeState)
                }
            }
        }
        
        return result
    }
    
    static func filesInFolderElementsConfig(for status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
        case .trashed:
            if viewType == .actionSheet {
                result = [.select] + ElementTypes.trashState
            } else {
                result = ElementTypes.trashState
            }
        default:
            switch viewType {
            case .bottomBar:
                result = [.share, .move, .moveToTrash]
            case .actionSheet:
                result = [.select]
            case .selectionMode:
                result = [.rename]
            case .actionSheetWithoutChangeCover:
                result = [.select]
            }
        }

        return result
    }
    
    static func muisicPlayerElementConfig(for status: ItemStatus, item: Item) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
        case .trashed:
            result = [.info] + ElementTypes.trashState
        default:
            result = item.favorites ? [.removeFromFavorites] : [.addToFavorites]
        }

        return result
    }
    
    static func specifiedMoreActionTypes(for status: ItemStatus, item: BaseDataSourceItem) -> [ElementTypes] {
        if status == .trashed {
            return[.info] + ElementTypes.trashState
        }
        
        guard let item = item as? Item else {
            return []
        }

        var types = [ElementTypes]()
        if !item.isOwner {
            //shared with me items
            types.append(.info)
            if let grantedPermissions = item.privateSharePermission?.granted {
                if grantedPermissions.contains(.read) {
                    if item.fileType.isContained(in: [.image, .video]) {
                        types.append(.download)
                    } else {
                        types.append(.downloadDocument)
                    }
                }
                
                if grantedPermissions.contains(.delete) {
                    if !item.isReadOnlyFolder {
                        types.append(.moveToTrashShared)
                    }
                }
            }

            if item.isMainFolder {
                types.append(.leaveSharing)
            }

            return types
        }
        
        if item.fileType == .photoAlbum {
            types = [.shareAlbum, .download, .moveToTrash, .removeAlbum, .albumDetails]
        } else if item.fileType.isFaceImageType || item.fileType.isFaceImageAlbum {
            types = [.shareAlbum, .albumDetails, .download]
        } else {
            types = [.info]
            
            let shareInfo = ElementTypes.allowedTypes(for: [item])
            if !shareInfo.isEmpty {
                types.append(contentsOf: shareInfo)
            }
            
            types.append(.move)
            types.append(item.favorites ? .removeFromFavorites : .addToFavorites)
            if !item.isReadOnlyFolder {
                types.append(.moveToTrash)
            }
            
            if item.fileType == .image || item.fileType == .video {
                types.append(.download)
            } else if item.fileType == .audio || item.fileType.isDocumentPageItem {
                types.append(.downloadDocument)
            }
        }

        if item.isShared && item.isMainFolder {
            types.append(.endSharing)
        }
        
        return types
    }
    
    static func allowedTypes(for items: [BaseDataSourceItem]) -> [ElementTypes] {
        var allowedTypes = [ElementTypes]()
        
        if items.contains(where: { $0.fileType == .folder}) {
            allowedTypes = [.shareLink, .sharePrivate]
        } else if items.contains(where: { return $0.fileType != .image && $0.fileType != .video && !$0.fileType.isDocumentPageItem && $0.fileType != .audio}) {
            allowedTypes = [.shareLink]
        } else {
            allowedTypes = [.shareOriginal, .shareLink, .sharePrivate]
        }
        
        if items.count > NumericConstants.numberOfSelectedItemsBeforeLimits {
            allowedTypes.remove(.shareOriginal)
        }
        
        if items.contains(where: { $0.isLocalItem }) {
            allowedTypes.remove(.sharePrivate)
        }
        
        return allowedTypes
    }
    
    func snackbarSuccessMessage(relatedItems: [BaseDataSourceItem] = [], divorseItems: DivorseItems? = nil) -> String? {
        if let divorseItems = divorseItems {
            return divorseSuccessMessage(divorseItems: divorseItems)
        }
        
        switch self {
        case .addToAlbum:
            return TextConstants.snackbarMessageAddedToAlbum
        case .addToFavorites:
            return TextConstants.snackbarMessageAddedToFavorites
        case .download:
            let format = TextConstants.snackbarMessageDownloadedFilesFormat
            return String(format: format, relatedItems.count)
        case .downloadDocument:
            let format = TextConstants.snackbarMessageDownloadedFilesFormat
            return String(format: format, relatedItems.count)
        case .edit:
            return TextConstants.snackbarMessageEditSaved
        case .emptyTrashBin:
            return TextConstants.trashBinDeleteAllComplete
        case .move:
            return TextConstants.snackbarMessageFilesMoved
        case .removeAlbum:
            return TextConstants.removeAlbumsSuccess
        case .removeFromAlbum, .removeFromFaceImageAlbum:
            return TextConstants.snackbarMessageRemovedFromAlbum
        case .removeFromFavorites:
            return TextConstants.snackbarMessageRemovedFromFavorites
        case .endSharing:
            return TextConstants.privateSharedEndSharingActionSuccess
        case .leaveSharing:
            return TextConstants.privateSharedLeaveSharingActionSuccess
        case .moveToTrashShared:
            return TextConstants.moveToTrashItemsSuccessText
        default:
            return nil
        }
    }
    
    func alertSuccessMessage(divorseItems: DivorseItems? = nil) -> String? {
        if let divorseItems = divorseItems {
            return divorseSuccessMessage(divorseItems: divorseItems)
        }
        
        switch self {
        case .download:
            return TextConstants.popUpDownloadComplete
        case .downloadDocument:
            return TextConstants.popUpDownloadComplete
        case .emptyTrashBin:
            return TextConstants.trashBinDeleteAllComplete
        case .removeAlbum:
            return TextConstants.removeAlbumsSuccess
        default:
            return nil
        }
    }
    
    private typealias SuccessLocalizationTriplet = (items: String, albums: String, folders: String)
    
    private func localizationTriplet() -> SuccessLocalizationTriplet {
        let triplet: SuccessLocalizationTriplet
        switch self {
        case .moveToTrash:
            triplet = SuccessLocalizationTriplet(
                items: TextConstants.moveToTrashItemsSuccessText,
                albums: TextConstants.moveToTrashAlbumsSuccessText,
                folders: TextConstants.moveToTrashFoldersSuccessText
            )
            
        case .unhide:
            triplet = SuccessLocalizationTriplet(
                items: TextConstants.unhideItemsSuccessText,
                albums: TextConstants.unhideAlbumsSuccessText,
                folders: TextConstants.unhideFoldersSuccessText
            )
            
        case .delete:
            triplet = SuccessLocalizationTriplet(
                items: TextConstants.deleteItemsSuccessText,
                albums: TextConstants.deleteAlbumsSuccessText,
                folders: TextConstants.deleteFoldersSuccessText
            )
            
        case .restore:
            triplet = SuccessLocalizationTriplet(
                items: TextConstants.restoreItemsSuccessText,
                albums: TextConstants.restoreAlbumsSuccessText,
                folders: TextConstants.restoreFoldersSuccessText
            )
        
        case .hide:
            triplet = SuccessLocalizationTriplet(
                items: TextConstants.hideSuccessPopupMessage,
                albums: TextConstants.hideAlbumsSuccessPopupMessage,
                folders: ""
            )
            
        default:
            triplet = SuccessLocalizationTriplet(
                items: "",
                albums: "",
                folders: ""
            )
            assertionFailure("unknown ElementType")
        }
        
        return triplet
    }
    
    func divorseSuccessMessage(divorseItems: DivorseItems) -> String {
        let localizations = localizationTriplet()

        let text: String
        switch divorseItems {
        case .items:
            text = localizations.items
            
        case .albums:
            text = localizations.albums
            
        case .folders:
            text = localizations.folders
        }
        
        return text
    }
    
    func actionTitle(fileType: FileType? = nil) -> String {
        switch self {
        case .info:
            return TextConstants.actionSheetInfo
        case .edit:
            return TextConstants.actionSheetEdit
        case .download, .downloadDocument:
            return TextConstants.actionSheetDownload
        case .moveToTrash, .moveToTrashShared, .delete:
            return TextConstants.actionSheetDelete
        case .hide:
            var title = TextConstants.actionSheetHide
            if fileType?.isFaceImageAlbum == true || fileType == .photoAlbum {
                title = TextConstants.actionSheetHideSingleAlbum
            }
            return title
            
        case .unhide:
            return TextConstants.actionSheetUnhide
        case .restore:
            return TextConstants.actionSheetRestore
        case .move:
            return TextConstants.actionSheetMove
        case .share, .shareAlbum:
            return TextConstants.actionSheetShare
        case .emptyTrashBin:
            return TextConstants.actionSheetEmptyTrashBin
        case .photos:
            return TextConstants.actionSheetPhotos
        case .createAlbum:
            return TextConstants.actionSheetAddToAlbum
        case .addToAlbum:
            return TextConstants.actionSheetAddToAlbum
        case .albumDetails:
            return TextConstants.actionSheetAlbumDetails
        case .makeAlbumCover:
            return localized(.changeAlbumCoverSetPhoto)
        case .removeFromAlbum, .removeFromFaceImageAlbum:
            return TextConstants.actionSheetRemoveFromAlbum
        case .backUp:
            return TextConstants.actionSheetBackUp
        case .copy:
            return TextConstants.actionSheetCopy
        case .createStory:
            return TextConstants.actionSheetCreateStory
        case .iCloudDrive:
            return TextConstants.actionSheetiCloudDrive
        case .lifeBox:
            return TextConstants.actionSheetLifeBox
        case .more:
            return TextConstants.actionSheetMore
        case .musicDetails:
            return TextConstants.actionSheetMusicDetails
        case .addToPlaylist:
            return TextConstants.actionSheetAddToPlaylist
        case .addToCmeraRoll:
            return TextConstants.actionSheetDownloadToCameraRoll
        case .addToFavorites:
            return TextConstants.actionSheetAddToFavorites
        case .removeFromFavorites:
            return TextConstants.actionSheetRemoveFavorites
        case .documentDetails:
            return TextConstants.actionSheetDocumentDetails
        case .select:
            return TextConstants.actionSheetSelect
        case .selectAll:
            return TextConstants.actionSheetSelectAll
        case .selectMode:
            return localized(.selectMode)
        case .onlyUnreadOn:
            return localized(.onlyUnread)
        case .onlyUnreadOff:
            return localized(.onlyUnread)
        case .onlyShowAlertsOn:
            return localized(.onlyAlert)
        case .onlyShowAlertsOff:
            return localized(.onlyAlert)
        case .deleteAll:
            return localized(.deleteAll)
        case .deSelectAll:
            return TextConstants.actionSheetDeSelectAll
        case .print:
            return localized(.photoPrint)
        case .smash:
            return TextConstants.tabBarSmashLabel
        case .rename:
            return TextConstants.actionSheetRename
        case .removeAlbum:
            return TextConstants.actionSheetRemove
        case .deleteDeviceOriginal:
            return TextConstants.actionSheetDeleteDeviceOriginal
        case .changeCoverPhoto:
            return TextConstants.actionSheetChangeCover
        case .changePeopleThumbnail:
            return localized(.changePersonThumbnail)
        case .makePersonThumbnail:
            return localized(.changePersonThumbnailSetPhoto)
        case .instaPick:
            return TextConstants.newInstaPick
        case .endSharing:
            return TextConstants.privateSharedEndSharingActionTitle
        case .leaveSharing:
            return TextConstants.privateSharedLeaveSharingActionTitle
        case .shareOriginal:
            return TextConstants.actionSheetShareOriginalSize
        case .shareLink:
            return TextConstants.actionSheetShareShareViaLink
        case .sharePrivate:
            return TextConstants.actionSheetSharePrivate
        case .galleryAll:
            return TextConstants.galleryFilterActionSheetAll
        case .galleryPhotos:
            return TextConstants.topBarPhotosFilter
        case .galleryVideos:
            return TextConstants.topBarVideosFilter
        case .gallerySync:
            return TextConstants.galleryFilterActionSheetSynced
        case .galleryUnsync:
            return TextConstants.galleryFilterActionSheetUnsynced
        case .officeFilterAll:
            return localized(.officeFilterAll)
        case .officeFilterPdf:
            return localized(.officeFilterPdf)
        case .officeFilterWord:
            return localized(.officeFilterWord)
        case .officeFilterCell:
            return localized(.officeFilterCell)
        case .officeFilterSlide:
            return localized(.officeFilterSlide)
        default:
            return ""
        }
    }

    var editingBarTitle: String {
        switch self {
        case .share:
            return TextConstants.tabBarShareLabel
        case .info:
            return TextConstants.tabBarInfoLabel
        case .edit:
            return TextConstants.tabBarEditeLabel
        case .delete:
            return TextConstants.tabBarDeleteLabel
        case .emptyTrashBin:
            return ""
        case .deleteDeviceOriginal:
            return ""
        case .move:
            return TextConstants.tabBarMoveLabel
        case .sync:
            return TextConstants.tabBarSyncLabel
        case .syncInProgress:
            return ""
        case .download:
            return TextConstants.tabBarDownloadLabel
        case .downloadDocument:
            return TextConstants.tabBarDownloadLabel
        case .undetermend:
            return ""
        case .rename:
            return ""
        case .removeAlbum:
            return TextConstants.tabBarRemoveAlbumLabel
        case .moveToTrash:
            return TextConstants.tabBarDeleteLabel
        case .restore:
            return TextConstants.actionSheetRestore
        case .createStory:
            return ""
        case .createAlbum:
            return ""
        case .copy:
            return ""
        case .addToFavorites:
            return ""
        case .removeFromFavorites:
            return ""
        case .addToAlbum:
            return TextConstants.tabBarAddToAlbumLabel
        case .backUp:
            return ""
        case .addToCmeraRoll:
            return ""
        case .removeFromAlbum:
            return TextConstants.tabBarRemoveLabel
        case .removeFromFaceImageAlbum:
            return TextConstants.tabBarRemoveLabel
        case .print:
            return localized(.photoPrint)
        case .changeCoverPhoto:
            return ""
        case .changePeopleThumbnail:
            return ""
        case .hide:
            return TextConstants.tabBarHideLabel
        case .unhide:
            return TextConstants.tabBarUnhideLabel
        case .smash:
            return TextConstants.tabBarSmashLabel
        case .photos:
            return ""
        case .iCloudDrive:
            return ""
        case .lifeBox:
            return ""
        case .more:
            return ""
        case .select:
            return ""
        case .selectAll:
            return TextConstants.actionSheetSelectAll
        case .selectMode:
            return ""
        case .deleteAll:
            return localized(.deleteAll)
        case .onlyUnreadOn:
            return ""
        case .onlyUnreadOff:
            return ""
        case .onlyShowAlertsOn:
            return ""
        case .onlyShowAlertsOff:
            return ""
        case .deSelectAll:
            return ""
        case .documentDetails:
            return ""
        case .addToPlaylist:
            return ""
        case .musicDetails:
            return ""
        case .shareAlbum:
            return ""
        case .makeAlbumCover:
            return ""
        case .makePersonThumbnail:
            return ""
        case .albumDetails:
            return ""
        case .instaPick:
            return ""
        case .endSharing:
            return ""
        case .leaveSharing:
            return ""
        case .moveToTrashShared:
            return ""
        case .shareOriginal:
            return ""
        case .shareLink:
            return ""
        case .sharePrivate:
            return ""
        case .galleryAll:
            return ""
        case .galleryPhotos:
            return ""
        case .galleryVideos:
            return ""
        case .gallerySync:
            return ""
        case .galleryUnsync:
            return ""
        case .collageSave:
            return TextConstants.save
        case .collageDelete:
            return TextConstants.actionSheetDelete
        case .collageChange:
            return TextConstants.change
        case .collageCancel:
            return TextConstants.cancel
        case .officeFilterAll:
            return ""
        case .officeFilterPdf:
            return ""
        case .officeFilterWord:
            return ""
        case .officeFilterCell:
            return ""
        case .officeFilterSlide:
            return ""
        }
    }

    var editingBarAccessibilityId: String {
        // TODO: Facelift, accessibilityId for editingBar items
        return ""
    }

    var icon: UIImage? {
        switch self {
        case .share:
            return Image.iconShare.image
        case .info:
            return Image.iconInfo.image
        case .edit:
            return Image.iconEdit.image
        case .delete:
            return Image.iconDelete2.image
        case .emptyTrashBin:
            return Image.iconDelete.image
        case .deleteDeviceOriginal:
            return Image.iconDelete.image
        case .move:
            return Image.iconMove.image
        case .sync:
            return Image.iconBackupBordered.image
        case .syncInProgress:
            return nil
        case .download:
            return Image.iconDownload.image
        case .downloadDocument:
            return UIImage(named: "downloadTB")
        case .undetermend:
            return nil
        case .rename:
            return Image.iconEdit.image
        case .removeAlbum:
            return Image.iconCancelBorder.image
        case .moveToTrash:
            return Image.iconDelete.image
        case .restore:
            return UIImage(named: "RestoreButtonIcon")
        case .createStory:
            return Image.iconStory.image
        case .createAlbum:
            return nil
        case .copy:
            return nil
        case .addToFavorites:
            return Image.iconFavorite.image
        case .removeFromFavorites:
            return Image.iconUnstar.image
        case .addToAlbum:
            return Image.iconAddToAlbum.image
        case .backUp:
            return nil
        case .addToCmeraRoll:
            return nil
        case .removeFromAlbum:
            return UIImage(named: "DeleteShareButton")
        case .removeFromFaceImageAlbum:
            return UIImage(named: "DeleteShareButton")
        case .print:
            return Image.iconPrint.image
        case .changeCoverPhoto:
            return Image.iconChangePhoto.image
        case .changePeopleThumbnail:
            return Image.iconChangePerson.image
        case .hide:
            return Image.iconHideUnselect.image
        case .unhide:
            return Image.iconHideSee.image
        case .smash:
            return UIImage(named: "SmashButtonIcon")
        case .photos:
            return nil
        case .iCloudDrive:
            return nil
        case .lifeBox:
            return nil
        case .more:
            return nil
        case .select:
            return Image.iconSelect.image
        case .selectAll:
            return Image.iconSelect.image
        case .selectMode:
            return Image.iconSelect.image
        case .deleteAll:
            return Image.iconDelete.image
        case .onlyUnreadOn:
            return Image.iconSwitchToggleOn.image
        case .onlyUnreadOff:
            return Image.iconSwitchToggleOff.image
        case .onlyShowAlertsOn:
            return Image.iconSwitchToggleOn.image
        case .onlyShowAlertsOff:
            return Image.iconSwitchToggleOff.image
        case .deSelectAll:
            return nil
        case .documentDetails:
            return nil
        case .addToPlaylist:
            return nil
        case .musicDetails:
            return nil
        case .shareAlbum:
            return Image.iconShare.image
        case .makeAlbumCover:
            return Image.iconChangePhoto.image
        case .makePersonThumbnail:
            return Image.iconChangePerson.image
        case .albumDetails:
            return Image.iconInfo.image
        case .instaPick:
            return Image.iconPrint.image
        case .endSharing:
            return Image.iconUnShare.image
        case .leaveSharing:
            return nil
        case .moveToTrashShared:
            return nil
        case .shareOriginal:
            return Image.iconSend.image
        case .shareLink:
            return Image.iconCopy.image
        case .sharePrivate:
            return Image.iconShare.image
        case .galleryAll:
            return Image.iconAll.image
        case .galleryPhotos:
            return Image.iconGalleryPhoto.image
        case .galleryVideos:
            return Image.iconVideo.image
        case .gallerySync:
            return Image.iconBackupCheck.image
        case .galleryUnsync:
            return Image.iconBackupUncheck.image
        case .collageSave:
            return Image.iconEdit.image
        case .collageChange:
            return Image.iconChangePhoto.image
        case .collageDelete:
            return Image.iconDeletePlain.image
        case .collageCancel:
            return Image.iconCancelBorder.image
        case .officeFilterAll:
            return Image.iconFileAllNew.image
        case .officeFilterPdf:
            return Image.iconFilePdfNew.image
        case .officeFilterWord:
            return Image.iconFileDocNew.image
        case .officeFilterCell:
            return Image.iconFileXlsNew.image
        case .officeFilterSlide:
            return Image.iconFilePptNew.image
        }
    }
}
