//
//  MoreActionsConfig.swift
//  Depo
//
//  Created by Aleksandr on 7/1/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct MoreActionsSetupConfig {
    let syncTypes: [MoreActionsConfig.CellSyncType]
    let selectedSyncTypeIndex: Int
    let availableViewType: [MoreActionsConfig.ViewType]
    let selectedViewTypeIndex: Int
    let availableSortTypes: [MoreActionsConfig.SortRullesType], selectedSortTypeIndex: Int
    let filterTypes: [MoreActionsConfig.MoreActionsFileType], selectedFilterFileTypeIndexes: [Bool]
    let selectionTypes: [MoreActionsConfig.SelectedType]
}

enum SortedRules: Int {
    case timeUp = 1
    case timeDown = 2
    case lettersAZ = 3
    case lettersZA = 4
    case sizeAZ = 5
    case sizeZA = 6
    
    var stringValue: String {
        switch self {
        case .timeUp:
            return TextConstants.sortTimeNewOldTitle
            
        case .timeDown:
            return TextConstants.sortTimeOldNewTitle
            
        case .lettersAZ:
            return TextConstants.sortTypeAlphabeticAZTitle
            
        case .lettersZA:
            return TextConstants.sortTypeAlphabeticZATitle
            
        case .sizeZA:
            return TextConstants.sortTimeSizeTitle
            
        case .sizeAZ:
            return TextConstants.sortTimeSizeTitle
        }
    }
}

class MoreActionsConfig {
    
    enum CellSyncType: CustomStringConvertible {
        case all
        case sync
        case notSync
        
        var description: String {
            switch self {
            case .all:
                return "All"
            case .sync:
                return "Sync"
            case .notSync:
                return "Not Sync"
            }
        }
        
        func convertToSyncWrapperedStatus() -> SyncWrapperedStatus {
            
            switch self {
                case .notSync:
                    return .notSynced
                case .sync:
                    return .synced
                case.all:
                    return .synced
            }
        }
    }
    
    enum CellSectionType: CustomStringConvertible {
        case syncType
        case viewType
        case sortType
        case filterType
        case selectionType
        
        var description: String {
            switch self {
            case .syncType:
                return TextConstants.syncTypeTitle
            case .viewType:
                return TextConstants.viewTypeTitle
            case .sortType:
                return TextConstants.sortTypeTitle
            case .filterType:
                return  TextConstants.fileTypeTitle
            case .selectionType:
                return TextConstants.selectionTypeTitle
            }
        }
    }
    
    enum MoreActionsViewAppearance {
        case regular
        case tableLike
    }
    
    enum ViewType: CustomStringConvertible {
        case Grid
        case List
        case None
        
        var description: String {
            switch self {
            case .Grid:
                return TextConstants.viewTypeGridTitle
            case .List:
                return TextConstants.viewTypeListTitle
            default:
                return "None"
            }
        }
    }
    
    enum SortRullesType: CustomStringConvertible {
        case AlphaBetricAZ
        case AlphaBetricZA
        case TimeNewOld
        case TimeOldNew
        case Largest
        case Smallest
        case None
        
        var description: String {
            switch self {
            case .AlphaBetricAZ:
                return TextConstants.sortTypeAlphabeticAZTitle
            case .AlphaBetricZA:
                return TextConstants.sortTypeAlphabeticZATitle
            case .TimeNewOld:
                return TextConstants.sortTimeNewOldTitle
            case .TimeOldNew:
                return TextConstants.sortTimeOldNewTitle
            case .Largest:
                return TextConstants.sortTimeSizeLargestTitle
            case .Smallest:
                return TextConstants.sortTimeSizeSmallestTitle
            default:
                return "None"
            }
        }
    }
    
    enum MoreActionsFileType: CustomStringConvertible {
        case Video
        case Music
        case Docs
        case Photo
        case Album
        case Folder
        case All
        case None
        case Duplicates
        
        //FIXME: temporary "fix"
        case onlyFavorites
        //
        
        var description: String {
            switch self {
            case .Video:
                return TextConstants.fileTypeVideoTitle
            case .Music:
                return TextConstants.fileTypeMusicTitle
            case .Docs:
                return TextConstants.fileTypeDocsTitle
            case .Photo:
                return TextConstants.fileTypePhotosTitle
//            case .All:
//                return TextConstants.file
            case .Album:
                return TextConstants.fileTypeAlbumTitle
            case .Folder:
                return TextConstants.fileTypeFolderTitle
            default:
                return ""
            }
        }
        
        func convertToFileType() -> FileType {
            
            switch self {
            case .Video:
                return .video
                
            case .Music:
                return .audio
                
            case .Photo:
                return .image
                
            case .Folder:
                return .folder
                
            case .Docs:
                // don't use only 
                return .unknown
            
            case .All:
                return .unknown
                
            case .Album:
                return .photoAlbum
                
            default:
                return .unknown
            }
        }
        
        func convertToGeneralFilterFileType() -> GeneralFilesFiltrationType {
            switch self {
            case .Video:
                return .fileType(.video)
                
            case .Music:
                return .fileType(.audio)
                
            case .Photo:
                return .fileType(.image)
                
            case .Folder:
                return .fileType(.folder)
                
            case .Docs:
                // don't use only
                return .fileType(.unknown)
                
            case .All:
                return .fileType(.unknown)
                
            case .Album:
                return .fileType(.photoAlbum)
                
            default:
                return .fileType(.unknown)
            }
        }
    }
    
    enum SelectedType: CustomStringConvertible {
        case Selected
        case All
        case None
        
        var description: String {
            switch self {
            case .Selected:
                return TextConstants.selectedTypeSelectedTitle
            case .All:
                return TextConstants.selectedTypeSelectedAllTitle
            default:
                return ""
            }
        }
    }
    
}
