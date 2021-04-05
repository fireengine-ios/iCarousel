//
//  PrivateShareType.swift
//  Depo
//
//  Created by Konstantin Studilin on 15.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

indirect enum PrivateShareType: Equatable {
    case myDisk
    case byMe
    case withMe
    case innerFolder(type: PrivateShareType, folderItem: PrivateSharedFolderItem)
    case sharedArea
    case trashBin
    
    var title: String {
        let title: String
        switch self {
            case .myDisk:
                title = TextConstants.tabBarItemMyDisk
            case .byMe:
                title = TextConstants.topBarSegmentSharedByMe
            case .withMe:
                title = TextConstants.topBarSegmentSharedWithMe
            case .innerFolder(_, let folder):
                title = folder.name
            case .sharedArea:
                title = TextConstants.tabBarItemSharedArea
            case .trashBin:
                title = TextConstants.trashBinPageTitle
        }
        return title
    }
    
    var rootType: PrivateShareType {
        return veryRootType(for: self)
    }
    
    var emptyViewType: EmptyView.ViewType {
        switch self {
            case .byMe:
                return .sharedBy
            case .withMe:
                return .sharedWith
            case .innerFolder:
                if rootType == .trashBin {
                    return .trashBinInnerFolder
                }
                return .sharedInnerFolder
            case .sharedArea:
                return .sharedArea
            case .myDisk:
                return .myDisk
            case .trashBin:
                return .trashBin
        }
    }

    var isTabBarNeeded: Bool {
        return !isTrashBinRelated
    }

    var isTrashBinRelated: Bool {
        switch self {
        case .trashBin:
            return true
        case .innerFolder(let folderType, _):
            return folderType == .trashBin ? true : false
        case .byMe, .myDisk, .sharedArea, .withMe:
            return false
        }
    }
    
    //isSelectionAllowed is predefined by the veryRootType only
    var isSelectionAllowed: Bool {
        switch self {
            case .myDisk:
                return true
                
            case .byMe:
                return true
                
            case .withMe:
                return true
                
            case .innerFolder:
                return veryRootType(for: self).isSelectionAllowed
                
            case .sharedArea:
                return true

            case .trashBin:
                return true
        }
    }
    
    //with this flag we check if we need to show search bar or not
    var isSearchAllowed: Bool {
        switch self {
            case .myDisk, .sharedArea:
                return true
                
            case .byMe, .withMe, .innerFolder, .trashBin:
                return false
        }
    }
    
    //floatingButtonTypes is predefined by the veryRootType + type itself
    func floatingButtonTypes(rootPermissions: SharedItemPermission?) -> [FloatingButtonsType] {
        let typeAndRoot = (self, veryRootType(for: self))
        
        switch typeAndRoot {
            case (.myDisk, _):
                if rootPermissions?.granted?.contains(.create) == true {
                    return [.upload(type: .regular), .uploadFiles(type: .regular),  .newFolder(type: .regular)]
                }
                return []
                
            case (.sharedArea, _):
                if rootPermissions?.granted?.contains(.create) == true {
                    return [.upload(type: .sharedArea), .uploadFiles(type: .sharedArea), .newFolder(type: .sharedArea)]
                }
                return []
            
            case (.byMe, _):
                return []
                
            case (.withMe, _):
                return []
                
            case (.innerFolder(_, let folder), let veryRootType):
                return floatingButtonTypes(innerFolderVeryRootType: veryRootType, permissions: folder.permissions.granted ?? [])

            case (.trashBin, _):
                return []
        }
    }
    
    private func floatingButtonTypes(innerFolderVeryRootType: PrivateShareType, permissions: [PrivateSharePermission]) -> [FloatingButtonsType] {
        switch innerFolderVeryRootType {
            case .myDisk:
                if permissions.contains(.create) {
                    return [ .upload(type: .regular), .uploadFiles(type: .regular), .newFolder(type: .regular)]
                }
                return []
                
            case .byMe:
                return [.upload(type: .regular), .uploadFiles(type: .regular), .newFolder(type: .regular)]
                
            case .withMe:
                if permissions.contains(.create) {
                    return [.upload(type: .sharedWithMe), .uploadFiles(type: .sharedWithMe), .newFolder(type: .sharedWithMe)]
                }
                return []
                
            case .sharedArea:
                if permissions.contains(.create) {
                    return [.upload(type: .sharedArea), .uploadFiles(type: .sharedArea), .newFolder(type: .sharedArea)]
                }
                return []

            case .trashBin:
                return []
                
            case .innerFolder:
                assertionFailure("should not be the case, innerFolderVeryRootType must not be the innerFolder")
                return []
        }
    }
    
    private func veryRootType(for type: PrivateShareType) -> PrivateShareType {
        switch type {
            case .byMe, .withMe, .myDisk, .sharedArea, .trashBin:
                return type
                
            case .innerFolder(type: let rootType, _):
                return veryRootType(for: rootType)
        }
    }
}

