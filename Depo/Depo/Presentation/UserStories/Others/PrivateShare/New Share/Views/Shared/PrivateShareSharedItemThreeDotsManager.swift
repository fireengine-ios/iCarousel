//
//  PrivateShareSharedItemThreeDotsManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 18.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


final class PrivateShareSharedItemThreeDotsManager {
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func showActions(for privateShareType: PrivateShareType, item: WrapData, sender: Any?) {
        switch privateShareType {
            case .byMe:
                let types = rootScreenActionTypes(for: privateShareType, item: item)
                alert.show(with: types, for: [item], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .withMe:
                let types = rootScreenActionTypes(for: privateShareType, item: item)
                alert.show(with: types, for: [item], presentedBy: sender, onSourceView: nil, viewController: nil)
                
            case .innerFolder:
                let types = innerFolderActionTypes(for: privateShareType.rootType, item: item)
                alert.show(with: types, for: [item], presentedBy: sender, onSourceView: nil, viewController: nil)
        }
    }
    
    func handleAction(type: ElementTypes, item: Item, sender: Any?) {
        alert.handleAction(type: type, items: [item], sender: sender)
    }
    
    private func rootScreenActionTypes(for shareType: PrivateShareType, item: WrapData) -> [ElementTypes] {
        var types = innerFolderActionTypes(for: shareType.rootType, item:  item)
        
        switch shareType {
            case .byMe:
                types.append(.endSharing)
                
            case .withMe:
                types.append(.leaveSharing)
                
            default:
                break
        }
        
        
        return types
    }
    
    private func innerFolderActionTypes(for rootType: PrivateShareType, item: WrapData) -> [ElementTypes] {
        switch rootType {
            case .byMe:
                var types: [ElementTypes] = [.info, .share, .move]
                
                types.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                if !item.isReadOnlyFolder {
                    types.append(.moveToTrash)
                }
                
                if item.fileType == .image || item.fileType == .video {
                    types.append(.download)
                    
                } else if item.fileType == .audio || item.fileType.isDocumentPageItem {
                    types.append(.downloadDocument)
                }
                
                return types
                
            case .withMe:
                var types: [ElementTypes] = [.info]
                
                if let grantedPermissions = item.privateSharePermission?.granted {
                    if grantedPermissions.contains(.read) {
                        if item.fileType.isContained(in: [.image, .video]) {
                            types.append(.download)
                        } else {
                            types.append(.downloadDocument)
                        }
                        
                        if grantedPermissions.contains(.delete) {
                            if !item.isReadOnlyFolder {
                                types.append(.moveToTrashShared)
                            }
                        }
                    }
                }
                    return types

            case .innerFolder:
                assertionFailure("should not be the case")
                return []
        }
        
    }
}
