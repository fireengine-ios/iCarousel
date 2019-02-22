//
//  PhotoVideoThreeDotMenuManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PhotoVideoThreeDotMenuManager {
    
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func showActions(for items: [WrapData], isSelectingMode: Bool) {
        if isSelectingMode {
            actionsForImageItems(items) { [weak self] types in
                // TODO: - check on iPad without sender -
                self?.alert.show(with: types, for: items, presentedBy: nil, onSourceView: nil, viewController: nil)
            }
        } else {
            self.alert.show(with: [.select], for: [], presentedBy: nil, onSourceView: nil, viewController: nil)
        }
    }
    
    private func actionsForImageItems(_ items: [WrapData], completion: @escaping ([ElementTypes]) -> Void) {
        
        let remoteItems = items.filter { !$0.isLocalItem }
        
        var actionTypes: [ElementTypes]
        
        /// locals only
        if remoteItems.isEmpty {
            actionTypes = [.createStory]
            completion(actionTypes)
            
            /// local and remotes or remotes only
        } else {
            actionTypes = [.createStory, .print, .deleteDeviceOriginal, .addToFavorites]
            
            /// remove .removeFromFavorites if need
            let thereIsFavorite = (remoteItems.first(where: { $0.favorites }) != nil)
            if thereIsFavorite {
                actionTypes.append(.removeFromFavorites)
            }
            
            /// remove .deleteDeviceOriginal if need
            MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: remoteItems) { duplicates in
                if duplicates.isEmpty, let deleteDeviceOriginalIndex = actionTypes.index(of: .deleteDeviceOriginal) {
                    actionTypes.remove(at: deleteDeviceOriginalIndex)
                }
                completion(actionTypes)
            }
        }
    }
    
}
