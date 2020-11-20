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
                
            case .innerFolder(type: let shareType, uuid: _, name: _):
                let types = innerFolderActionTypes(for: shareType, item: item)
                alert.show(with: types, for: [item], presentedBy: sender, onSourceView: nil, viewController: nil)
        }
    }
    
    
    private func rootScreenActionTypes(for shareType: PrivateShareType, item: WrapData) -> [ElementTypes] {
        var types = innerFolderActionTypes(for: shareType.rootType, item:  item)
        
        switch shareType {
            case .byMe:
                types.append(.endSharing)
                
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
                return []

            case .innerFolder:
                assertionFailure("should not be the case")
                return []
        }
        
    }
}
