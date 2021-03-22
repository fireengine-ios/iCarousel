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
    case delete
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
    
    static var trashState: [ElementTypes] = [.restore, .delete]
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
        if grantedPermissions.contains(.writeAcl) {
            result.append(.privateShare)
        }
        
        if grantedPermissions.contains(.read) {
            if item.fileType.isContained(in: [.image, .video]) {
                result.append(.download)
            } else {
                result.append(.downloadDocument)
            }
            result.append(.share)
        }
        
        if grantedPermissions.contains(.delete) {
            if !item.isReadOnlyFolder {
                result.append(.moveToTrashShared)
            }
        }
        
        if status == .trashed {
            result = ElementTypes.trashState
        }
        
        result.append(.info)
        
        return result
    }
    
    static func filesInFolderElementsConfig(for status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
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
        case .trashed:
            result = [.info] + ElementTypes.trashState
        default:
            result = item.favorites ? [.removeFromFavorites] : [.addToFavorites]
        }

        return result
    }
    
    static func specifiedMoreActionTypes(for status: ItemStatus, item: BaseDataSourceItem) -> [ElementTypes] {
        //TODO: allow move and add/remove favorites if api is ready
        
        if status == .trashed {
            return ElementTypes.trashState + [.info]
        }
        
        guard let item = item as? Item else {
            return []
        }
        
        var types: [ElementTypes] = [.select]

        if let grantedPermissions = item.privateSharePermission?.granted {
            if grantedPermissions.contains(.read) {
                if item.fileType.isContained(in: [.image, .video]) {
                    types.append(.download)
                } else {
                    types.append(.downloadDocument)
                }
            }
            
            if grantedPermissions.contains(.writeAcl) || grantedPermissions.contains(.read)  {
                types.append(.share)
            }
            
            // TODO: - Add / Delete permission check  //grantedPermissions.contains(.writeAcl)
            if item.isShared {
                if item.privateShareType == .withMe {
                    types.append(.leaveSharing)
                } else if item.privateShareType == .byMe {
                    types.append(.endSharing)
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
            case .delete, .moveToTrashShared, .moveToTrash:
                return TextConstants.deleteSuccess
            case .rename:
                return TextConstants.renameSuccess
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
        case .moveToTrash, .moveToTrashShared, .delete:
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
        default:
            return ""
        }
    }
}
