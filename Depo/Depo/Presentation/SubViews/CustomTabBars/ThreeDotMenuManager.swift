//
//  ThreeDotMenuManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class ThreeDotMenuManager {
    
    static func actionsForImageItems(_ items: [WrapData], completion: @escaping ([ElementTypes]) -> Void) {
        
        let remoteItems = items.filter { !$0.isLocalItem}
        
        var actionTypes: [ElementTypes]
        
        /// locals only
        if remoteItems.isEmpty {
            actionTypes = [.createStory]
            completion(actionTypes)
            
            /// local and remotes or remotes only
        } else {
            actionTypes = [.createStory, .print, .deleteDeviceOriginal, .addToFavorites]
            
            let thereIsFavorite = (remoteItems.first(where: { $0.favorites }) != nil)
            if thereIsFavorite {
                actionTypes.append(.removeFromFavorites)
            }
            
            MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: remoteItems) { duplicates in
                if duplicates.isEmpty, let deleteDeviceOriginalIndex = actionTypes.index(of: .deleteDeviceOriginal) {
                    actionTypes.remove(at: deleteDeviceOriginalIndex)
                }
                completion(actionTypes)
            }
        }
    }
    
}
