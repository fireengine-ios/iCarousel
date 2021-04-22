//
//  ElementTypes.swift
//  Depo
//
//  Created by Andrei Novikau on 5/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum UniversalViewType {
    case bottomBar
    case actionSheet
    case selectionMode
}

enum ElementTypes {
    case share
    case info//one for alert one for tab
    case deletePermanently
    case emptyTrashBin
    case move
    case download
    case downloadDocument
    case undetermend
    case rename
    case moveToTrash
    case restore
    
    //used only in alert sheet:
    //photos:
    case copy
    case addToFavorites
    case removeFromFavorites
    case backUp
    case addToCmeraRoll
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
    //private share
    case privateShare
    case endSharing
    case leaveSharing
    case moveToTrashShared
    //changing role
    case editorRole
    case viewerRole
    case variesRole
    case removeRole
    
    static var trashState: [ElementTypes] = [.restore, .deletePermanently]
    static var activeState: [ElementTypes] = [.moveToTrash]

    static func detailsElementsConfig(for item: Item, status: ItemStatus) -> [ElementTypes] {
        var result = [ElementTypes]()
        
        guard let grantedPermissions = item.privateSharePermission?.granted,
              (grantedPermissions.contains(.read) ||
                grantedPermissions.contains(.writeAcl) ||
                grantedPermissions.contains(.delete))
        else {
            return result
        }
        
        //specific actions order
        if status == .trashed {
            result = item.privateSharePermission?.granted?.contains(.delete) == true ? ElementTypes.trashState : []
            
        } else {
            if grantedPermissions.contains(.read) {
                result.append(.share)
            }
            
            if grantedPermissions.contains(.writeAcl) {
                result.append(.privateShare)
            }
            
            if grantedPermissions.contains(.delete) {
                if !item.isReadOnlyFolder {
                    result.append(.moveToTrashShared)
                }
            }
            
            if grantedPermissions.contains(.read) {
                if item.fileType.isContained(in: [.image, .video]) {
                    result.append(.download)
                } else {
                    result.append(.downloadDocument)
                }
            }
            
            result.append(.info)
        }
        
        return result
    }
    
    static func filesInFolderElementsConfig(for status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
        case .trashed: // TODO check here if permissions contains DELETE and give appropriate action list for that
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
        case .trashed:
            result = [.info] + ElementTypes.trashState
        default:
            result = item.favorites ? [.removeFromFavorites] : [.addToFavorites]
        }

        return result
    }

    static func specifiedMoreActionTypesForTrashBin(for status: ItemStatus, item: WrapData) -> [ElementTypes] {
        var actionsArray: [ElementTypes] = [.select]
        if item.privateSharePermission?.granted?.contains(.delete) == true {
            actionsArray.append(contentsOf: [.restore, .deletePermanently])
        }
        actionsArray.append(.info)
        return actionsArray
    }
    
    static func specifiedMoreActionTypes(for status: ItemStatus, item: BaseDataSourceItem) -> [ElementTypes] {
        //TODO: allow move and add/remove favorites if api is ready
        var trashBinRelated = item.privateShareType == .trashBin
        if case .innerFolder = item.privateShareType, item.privateShareType.rootType == .trashBin {
            trashBinRelated = true
        }
        
        if trashBinRelated {
            return (item as? WrapData)?.privateSharePermission?.granted?.contains(.delete) ?? false ? [.select] + ElementTypes.trashState + [.info] : [.select, .info]
        }
        
        guard let item = item as? Item else {
            return []
        }
        
        var types: [ElementTypes] = [.select]

        if let grantedPermissions = item.privateSharePermission?.granted {
            if grantedPermissions.contains(.read) {
                types.append(.share)
            }
            
            if grantedPermissions.contains(.writeAcl) {
                types.append(.privateShare)
            }
            
            // TODO: - Add / Delete permission check  //grantedPermissions.contains(.writeAcl)
            if item.isFileSharedWithUser {
                if item.privateShareType == .withMe {
                    types.append(.leaveSharing)
                } else if item.privateShareType == .byMe {
                    types.append(.endSharing)
                }
            }
            
            if grantedPermissions.contains(.read) {
                if item.fileType.isContained(in: [.image, .video]) {
                    types.append(.download)
                } else {
                    types.append(.downloadDocument)
                }
            }
            
            if grantedPermissions.contains(.setAttribute) {
                types.append(.rename)
            }
            
            if grantedPermissions.contains(.delete) {
                if !item.isReadOnlyFolder {
                    types.append(.moveToTrashShared)
                }
            }
        }
        
        types.append(.info)

        return types
    }
    
    func snackbarSuccessMessage(relatedItems: [BaseDataSourceItem] = []) -> String? {
        switch self {
            case .addToFavorites:
                return TextConstants.snackbarMessageAddedToFavorites
            case .download, .downloadDocument:
                return TextConstants.downloadSuccess
            case .emptyTrashBin:
                return TextConstants.trashBinDeleteAllComplete
            case .move:
                return TextConstants.snackbarMessageFilesMoved
            case .removeFromFavorites:
                return TextConstants.snackbarMessageRemovedFromFavorites
            case .endSharing:
                return TextConstants.stopSharingSuccess
            case .leaveSharing:
                return TextConstants.leaveSharingSuccess
            case .moveToTrashShared, .moveToTrash:
                return TextConstants.deleteSuccess
            case .rename:
                return TextConstants.renameSuccess
            case .deletePermanently:
                return TextConstants.trashBinDeleteActionSucceed
            case .restore:
                return TextConstants.trashBinRestoreSucceed
            default:
                return nil
        }
    }
    
    func alertSuccessMessage() -> String? {
        switch self {
        case .download:
            return TextConstants.popUpDownloadComplete
        case .downloadDocument:
            return TextConstants.popUpDownloadComplete
        case .emptyTrashBin:
            return TextConstants.trashBinDeleteAllComplete
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
             
        case .restore:
            triplet = SuccessLocalizationTriplet(
                items: TextConstants.restoreItemsSuccessText,
                albums: TextConstants.restoreAlbumsSuccessText,
                folders: TextConstants.restoreFoldersSuccessText
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
    
    var actionTitle: String {
        switch self {
        case .info:
            return TextConstants.actionInfo
        case .download, .downloadDocument:
            return TextConstants.actionDownload
        case .moveToTrash, .moveToTrashShared:
            return TextConstants.actionDelete
        case .restore:
            return TextConstants.actionSheetRestore
        case .move:
            return TextConstants.actionSheetMove
        case .share, .shareAlbum:
            return TextConstants.actionShareCopy
        case .emptyTrashBin:
            return TextConstants.actionSheetEmptyTrashBin
        case .photos:
            return TextConstants.actionSheetPhotos
        case .makeAlbumCover:
            return TextConstants.actionSheetMakeAlbumCover
        case .backUp:
            return TextConstants.actionSheetBackUp
        case .copy:
            return TextConstants.actionSheetCopy
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
            return TextConstants.actionSelect
        case .selectAll:
            return TextConstants.actionSheetSelectAll
        case .deSelectAll:
            return TextConstants.actionSheetDeSelectAll
        case .rename:
            return TextConstants.actionRename
        case .endSharing:
            return TextConstants.actionStopSharing
        case .leaveSharing:
            return TextConstants.actionLeaveSharing
        case .privateShare:
            return TextConstants.actionSharePrivately
        case .deletePermanently:
            return TextConstants.trashBinDeleteAction
        default:
            return ""
        }
    }
}
