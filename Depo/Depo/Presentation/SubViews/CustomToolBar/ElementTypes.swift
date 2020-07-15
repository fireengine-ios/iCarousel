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
    
    static var trashState: [ElementTypes] = [.restore, .delete]
    static var hiddenState: [ElementTypes] = [.unhide, .moveToTrash]
    static var activeState: [ElementTypes] = [.hide, .moveToTrash]

    static func detailsElementsConfig(for item: Item, status: ItemStatus, viewType: DetailViewType) -> [ElementTypes] {
        var result: [ElementTypes]
        
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
//                        if Device.isTurkishLocale {
//                            result.append(.print) //FE-2439 - Removing Print Option for Turkish (TR) language
//                        }
                        
                        result.append(.edit)

                        if item.name?.isPathExtensionGif() == false {
                            result.append(.smash)
                        }
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
//                if Device.isTurkishLocale {
//                    result.append(.print) //FE-2439 - Removing Print Option for Turkish (TR) language
//                }
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
                    result.append(contentsOf: [.changeCoverPhoto] + ElementTypes.activeState)
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
//                if Device.isTurkishLocale {
//                    result.append(.print)  //FE-2439 - Removing Print Option for Turkish (TR) language
//                }
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
}
