//
//  ElementTypes.swift
//  Depo
//
//  Created by Andrei Novikau on 5/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

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
    case deSelectAll
    //doc viewing
    case documentDetails
    //music
    case addToPlaylist
    case musicDetails
    case shareAlbum
    case makeAlbumCover
    case albumDetails
    //instaPick
    case instaPick
    //private share
    case endSharing
    case leaveSharing
    case moveToTrashShared
    
    static var trashState: [ElementTypes] = [.restore, .delete]
    static var hiddenState: [ElementTypes] = [.unhide, .moveToTrash]
    static var activeState: [ElementTypes] = [.hide, .moveToTrash]

    static func detailsElementsConfig(for item: Item, status: ItemStatus, viewType: DetailViewType) -> [ElementTypes] {
        var result = [ElementTypes]()
        
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
                result = [.share, inProgress ? .syncInProgress : .sync, .info]
            } else {
                switch item.fileType {
                case .image, .video:
                    result = [.share, .download]
                    
                    if item.fileType == .image {

                        result.append(.edit)

                        if PrintService.isEnabled {
                            result.append(.print) //FE-2439 - Removing Print Option for Turkish (TR) language
                        }
                        // moved to three dots menu
//                        if item.name?.isPathExtensionGif() == false {
//                            result.append(.smash)
//                        }
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
                result = [.select, .shareAlbum, .download, .removeAlbum, .albumDetails]  + ElementTypes.activeState
                
            case .selectionMode:
                result = [.createStory, .addToFavorites, .removeFromFavorites]
                if PrintService.isEnabled {
                    result.append(.print) //FE-2439 - Removing Print Option for Turkish (TR) language
                }
                result.append(.removeFromAlbum)
            }
        }
        
        return result
    }
    
    static func faceImagePhotosElementsConfig(for item: Item, status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch viewType {
        case .bottomBar:
            switch status {
            case .hidden:
                result = ElementTypes.hiddenState
                
            case .trashed:
                result = ElementTypes.trashState
                
            default:
                result = [.share, .download, .addToAlbum] + ElementTypes.activeState
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
                    result.append(contentsOf: [.changeCoverPhoto, .share] + ElementTypes.activeState)
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
                if PrintService.isEnabled {
                    result.append(.print) //FE-2439 - Removing Print Option for Turkish (TR) language
                }
                result.append(.removeFromFaceImageAlbum)
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
            types = [.info, .share, .move]
            
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
            return TextConstants.actionSheetMakeAlbumCover
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
        case .deSelectAll:
            return TextConstants.actionSheetDeSelectAll
        case .print:
            return TextConstants.tabBarPrintLabel
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
        case .instaPick:
            return TextConstants.newInstaPick
        case .endSharing:
            return TextConstants.privateSharedEndSharingActionTitle
        case .leaveSharing:
            return TextConstants.privateSharedLeaveSharingActionTitle
        default:
            return ""
        }
    }
}
