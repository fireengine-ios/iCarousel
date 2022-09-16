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

    func showActions(for items: [WrapData], isSelectingMode: Bool, sender: Any?) {
        if isSelectingMode {
            actionsForItems(items) { [weak self] types in
                self?.alert.show(with: types, for: items, presentedBy: sender, onSourceView: nil, viewController: nil)
            }

        } else {
            self.alert.show(with: [.galleryAll,
                                   .gallerySync,
                                   .galleryUnsync,
                                   .galleryPhotos,
                                   .galleryVideos],
                            for: [], presentedBy: sender, onSourceView: nil, viewController: nil)
        }
    }
    
    private func actionsForItems(_ items: [WrapData], completion: @escaping ([ElementTypes]) -> Void) {
        
        let remoteItems = items.filter { !$0.isLocalItem }
        let containsPhotos = items.contains { $0.fileType == .image }
        
        var actionTypes: [ElementTypes]

        /// locals only
        if remoteItems.isEmpty {
            if containsPhotos {
                actionTypes = [.createStory, .addToAlbum]
            } else {
                actionTypes = []
            }
            completion(actionTypes)
            
            /// local and remotes or remotes only
        } else {
            if containsPhotos {
                actionTypes = [.createStory]
            } else {
                actionTypes = []
            }

            /// add .addToFavorites if need
            let hasUnfavorite = remoteItems.first(where: { !$0.favorites }) != nil
            if hasUnfavorite {
                actionTypes.append(.addToFavorites)
            }
            
            /// add .removeFromFavorites if need
            let hasFavorite = remoteItems.first(where: { $0.favorites }) != nil
            if hasFavorite {
                actionTypes.append(.removeFromFavorites)
            }
            
            ///FE-2455 Removing Print Option - Print option is displayed
            actionTypes.append(contentsOf: [.addToAlbum/*, .print*/])

            if containsPhotos, PrintService.isEnabled {
                actionTypes.append(.print)
            }
            
            /// remove .deleteDeviceOriginal if need
            MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: remoteItems) { duplicates in
                if !duplicates.isEmpty {
                    actionTypes.append(.deleteDeviceOriginal)
                }
                completion(actionTypes)
            }
        }
    }
}
