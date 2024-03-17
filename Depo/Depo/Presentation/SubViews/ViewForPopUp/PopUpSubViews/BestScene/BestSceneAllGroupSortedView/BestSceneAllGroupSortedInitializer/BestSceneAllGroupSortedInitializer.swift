//
//  BestSceneAllGroupSortedInitializer.swift
//  Depo
//
//  Created by Rustam Manafov on 04.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class BestSceneAllGroupSortedInitializer {
    class func initializeController(coverPhotoUrl: String, fileListUrls: [String], selectedId: Int, selectedGroupID: Int) -> UIViewController {
    
        let viewController = BestSceneAllGroupSortedViewController(coverPhotoUrl: coverPhotoUrl, fileListUrls: fileListUrls, selectedId: selectedId, selectedGroupID: selectedGroupID)
        
        return viewController
    }
}
