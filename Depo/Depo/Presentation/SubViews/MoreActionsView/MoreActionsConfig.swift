//
//  MoreActionsConfig.swift
//  Depo
//
//  Created by Aleksandr on 7/1/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum SortedRules: Int {
    case timeUp = 1
    case timeDown = 2
    case lettersAZ = 3
    case lettersZA = 4
    case sizeAZ = 5
    case sizeZA = 6
    case albumlettersAZ = 7
    case albumlettersZA = 8
    case timeUpWithoutSection = 9
    case timeDownWithoutSection = 10
    case metaDataTimeUp = 11
    case metaDataTimeDown = 12
    case lastModifiedTimeUp = 13
    case lastModifiedTimeDown = 14
    
    var stringValue: String {
        switch self {
        case .timeUp, .timeUpWithoutSection, .metaDataTimeUp, .lastModifiedTimeUp:
            return TextConstants.sortTimeNewOldTitle
            
        case .timeDown, .timeDownWithoutSection, .metaDataTimeDown, .lastModifiedTimeDown:
            
            return TextConstants.sortTimeOldNewTitle
            
        case .lettersAZ:
            return TextConstants.sortTypeAlphabeticAZTitle
            
        case .lettersZA:
            return TextConstants.sortTypeAlphabeticZATitle
            
        case .sizeZA:
            return TextConstants.sortTimeSizeTitle
            
        case .sizeAZ:
            return TextConstants.sortTimeSizeTitle
            
        case .albumlettersAZ:
            return TextConstants.sortTypeAlphabeticAZTitle
            
        case .albumlettersZA:
            return TextConstants.sortTypeAlphabeticZATitle
        }
    }
    
    var descriptionForTitle: String {
        switch self {
        case .lettersAZ, .lettersZA, .albumlettersAZ, .albumlettersZA:
            return TextConstants.sortHeaderAlphabetic
        case .timeUp, .timeUpWithoutSection, .metaDataTimeUp, .timeDown, .timeDownWithoutSection, .metaDataTimeDown, .lastModifiedTimeUp, .lastModifiedTimeDown :
            return TextConstants.sortHeaderTime
        case .sizeZA, .sizeAZ:
            return TextConstants.sortHeaderSize
        }
    }
    
    var sortingRules: SortType {
        switch self {
        case .timeUp, .timeDown, .timeUpWithoutSection, .timeDownWithoutSection:
            return .date
        case .metaDataTimeUp, .metaDataTimeDown:
            return .imageDate
        case .lettersAZ, .lettersZA:
            return .name
        case .sizeAZ, .sizeZA:
            return .size
        case .albumlettersAZ, .albumlettersZA:
            return .albumName
        case .lastModifiedTimeUp, .lastModifiedTimeDown:
            return .lastModifiedDate
        }
    }
    
    var sortOder: SortOrder {
        switch self {
        case .timeUp, .timeUpWithoutSection, .lettersAZ, .sizeAZ, .albumlettersAZ, .metaDataTimeUp, .lastModifiedTimeUp:
            return .desc
        case .timeDown, .timeDownWithoutSection, .lettersZA, .sizeZA, .albumlettersZA, .metaDataTimeDown, .lastModifiedTimeDown:
            return .asc
        }
    }
    
}

enum DateSortField {
    case createdDate
    case lastModifiedDate
    case metadate
    
    func sortDate(item: WrapData) -> Date? {
        switch self {
        case .createdDate:
            return item.creationDate
        case .lastModifiedDate:
            return item.lastModifiDate
        case .metadate:
            return item.metaDate
        }
    }
}

class MoreActionsConfig {
    
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
        case LettersAZ
        case LettersZA
        case TimeNewOld
        case TimeOldNew
        case metaDataTimeNewOld
        case metaDataTimeOldNew
        case lastModifiedTimeNewOld
        case lastModifiedTimeOldNew
        case Largest
        case Smallest
        case None
        
        var description: String {
            switch self {
            case .AlphaBetricAZ, .LettersAZ:
                return TextConstants.sortTypeAlphabeticAZTitle
            case .AlphaBetricZA, .LettersZA:
                return TextConstants.sortTypeAlphabeticZATitle
            case .TimeNewOld, .metaDataTimeNewOld, .lastModifiedTimeNewOld:
                return TextConstants.sortTimeNewOldTitle
            case .TimeOldNew, .metaDataTimeOldNew, .lastModifiedTimeOldNew:
                return TextConstants.sortTimeOldNewTitle
            case .Largest:
                return TextConstants.sortTimeSizeLargestTitle
            case .Smallest:
                return TextConstants.sortTimeSizeSmallestTitle
            default:
                return "None"
            }
        }
        
        var sortedRulesConveted: SortedRules {
            switch self {
            case .AlphaBetricAZ:
                return .lettersZA
            case .AlphaBetricZA:
                return .lettersAZ
            case .TimeNewOld:
                return .timeUp
            case .TimeOldNew:
                return .timeDown
            case .Largest:
                return .sizeAZ
            case .Smallest:
                return .sizeZA
            case .metaDataTimeNewOld:
                return .metaDataTimeUp
            case .metaDataTimeOldNew:
                return .metaDataTimeDown
            case .lastModifiedTimeNewOld:
                return .lastModifiedTimeUp
            case .lastModifiedTimeOldNew:
                return .lastModifiedTimeDown
            default:
                return .timeUp
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
