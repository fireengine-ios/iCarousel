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
    
    var rootType: PrivateShareType {
        return veryRootType(for: self)
    }
    
    var emptyViewType: EmptyView.ViewType {
        switch self {
            case .byMe:
                return .sharedBy
            case .withMe:
                return .sharedWith
            case .innerFolder, .myDisk:
                return .sharedInnerFolder
        case .sharedArea:
            return .sharedArea
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
                return false
                
            case .innerFolder:
                return veryRootType(for: self).isSelectionAllowed
                
            case .sharedArea:
                return true
        }
    }
    
    //floatingButtonTypes is predefined by the veryRootType + type itself
    func floatingButtonTypes(rootPermissions: SharedItemPermission?) -> [FloatingButtonsType] {
        let typeAndRoot = (self, veryRootType(for: self))
        
        switch typeAndRoot {
            case (.myDisk, _):
                //FIXME: SOMETHING WRONG WITTH ACCESS
//                if rootPermissions?.granted?.contains(.create) == true {
                    return [.newFolder(type: .regular), .upload(type: .regular), .uploadFiles(type: .regular)]
//                }
                return []
                
            case (.sharedArea, _):
                if rootPermissions?.granted?.contains(.create) == true {
                    return [.newFolder(type: .sharedArea), .upload(type: .sharedArea), .uploadFiles(type: .sharedArea)]
                }
                return []
            
            case (.byMe, _):
                return []
                
            case (.withMe, _):
                return []
                
            case (.innerFolder(_, let folder), let veryRootType):
                return floatingButtonTypes(innerFolderVeryRootType: veryRootType, permissions: folder.permissions.granted ?? [])
        }
    }
    
    private func floatingButtonTypes(innerFolderVeryRootType: PrivateShareType, permissions: [PrivateSharePermission]) -> [FloatingButtonsType] {
        switch innerFolderVeryRootType {
            case .myDisk:
                if permissions.contains(.create) {
                    return [.newFolder(type: .regular), .upload(type: .regular), .uploadFiles(type: .regular)]
                }
                return []
                
            case .byMe:
                return [.newFolder(type: .regular), .upload(type: .regular), .uploadFiles(type: .regular)]
                
            case .withMe:
                if permissions.contains(.create) {
                    return [.newFolder(type: .sharedWithMe), .upload(type: .sharedWithMe), .uploadFiles(type: .sharedWithMe)]
                }
                return []
                
            case .sharedArea:
                if permissions.contains(.create) {
                    return [.newFolder(type: .sharedArea), .upload(type: .sharedArea), .uploadFiles(type: .sharedArea)]
                }
                return []
                
            case .innerFolder:
                assertionFailure("should not be the case, innerFolderVeryRootType must not be the innerFolder")
                return []
                
            
        }
    }
    
    private func veryRootType(for type: PrivateShareType) -> PrivateShareType {
        switch type {
            case .byMe, .withMe, .myDisk, .sharedArea:
                return type
                
            case .innerFolder(type: let rootType, _):
                return veryRootType(for: rootType)
        }
    }
}

